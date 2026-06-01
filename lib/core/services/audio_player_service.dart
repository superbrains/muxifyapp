import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/audio_playback/models/track.dart';

typedef StreamUrlResolver = Future<String> Function(String trackId);

/// Singleton owning the app's only [AudioPlayer]. Survives navigation so audio
/// keeps playing across screen changes and into the background, where
/// `just_audio_background` connects this player to the OS notification and
/// lock-screen widget.
///
/// Reliability design (production-grade):
///  * Loads are serialised with [_loadToken] so rapid taps / overlapping loads
///    can never interleave and wedge the player.
///  * The visible [_queue] and the player's audio sources are kept aligned via
///    [_sourceToQueue]/[_queueToSource], so locked/unplayable tracks can stay
///    in the queue without breaking seek/swipe/current-index.
///  * Playback errors (e.g. an expired 1-hour SAS URL) are caught from
///    [AudioPlayer.playbackEventStream] and recovered by re-resolving the
///    stream URL once and resuming at the same position.
///  * Failures that can't be recovered are surfaced on [errorStream] so the UI
///    can toast instead of leaving a silent, dead player.
class AudioPlayerService {
  AudioPlayerService._() {
    _attachErrorMonitor();
  }

  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  final List<Track> _queue = [];
  StreamUrlResolver? _streamUrlResolver;

  // Maps between the visible queue and the player's audio-source list. The two
  // diverge whenever a queue track has no playable URL (locked content returns
  // ContentNotUnlocked → empty URL), so we must translate indices in both
  // directions for seek/current-index to stay correct.
  final List<int> _sourceToQueue = []; // sourceIndex -> queueIndex
  List<int?> _queueToSource = []; // queueIndex  -> sourceIndex (null if unplayable)

  // Monotonic load id. Every load/recovery bumps it; any async step that finds
  // a newer token aborts so only the most recent intent wins.
  int _loadToken = 0;

  // One recovery attempt per track id per load, so an unplayable source can't
  // spin the re-resolve loop forever.
  final Set<String> _recoveryAttempts = {};

  // Why each track failed to resolve a stream URL (track id -> reason), so the
  // exclusion log and surfaced error can state the real cause (HTTP status,
  // empty body, etc.) instead of a vague "no URL".
  final Map<String, String> _resolveFailure = {};
  bool _recovering = false;
  bool _interruptedByOs = false;
  bool _sessionWired = false;

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  StreamSubscription<PlaybackEvent>? _eventSub;

  AudioPlayer get player => _player;
  List<Track> get queue => List.unmodifiable(_queue);

  /// User-facing playback failures (already-friendly messages) for the UI to
  /// toast. Broadcast so multiple listeners (screen + mini-player) can attach.
  Stream<String> get errorStream => _errorController.stream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;
  Stream<bool> get shuffleModeEnabledStream => _player.shuffleModeEnabledStream;

  /// Wires a resolver used to fetch a stream URL for a [Track] that lacks one.
  /// Called by [AudioProvider] at construction so the service stays decoupled
  /// from `ArtistProfileProvider`.
  void setStreamUrlResolver(StreamUrlResolver resolver) {
    _streamUrlResolver = resolver;
  }

  /// The queue index of the track the player is currently positioned on,
  /// translated from the player's source index. Drives the carousel's active
  /// page so it lines up with the visible (possibly locked-padded) queue.
  int? get currentQueueIndex {
    final srcIdx = _player.currentIndex;
    if (srcIdx == null || srcIdx < 0 || srcIdx >= _sourceToQueue.length) {
      return null;
    }
    return _sourceToQueue[srcIdx];
  }

  Track? get currentTrack {
    if (_queue.isEmpty) return null;
    final qIdx = currentQueueIndex;
    if (qIdx == null || qIdx < 0 || qIdx >= _queue.length) return _queue.first;
    return _queue[qIdx];
  }

  bool get hasActiveTrack => _queue.isNotEmpty;

  /// Loads [tracks] into the queue and starts playback at [startIndex].
  ///
  /// Resolves stream URLs (in parallel) up front so just_audio can preload the
  /// upcoming sources in the background — the next track is buffered before the
  /// user ever swipes/taps next. Auto-plays as soon as the sources are set.
  Future<void> loadAndPlay(
    List<Track> tracks, {
    int startIndex = 0,
  }) async {
    if (tracks.isEmpty) return;
    final token = ++_loadToken;
    final start = startIndex.clamp(0, tracks.length - 1);
    Logger.info(
      'AudioPlayer.loadAndPlay: ${tracks.length} track(s), startIndex=$start, token=$token',
    );

    try {
      await _wireSession();

      final sw = Stopwatch()..start();
      final resolved = await _resolveTracks(tracks);
      sw.stop();
      Logger.info(
        'AudioPlayer.loadAndPlay: resolved ${resolved.length} track(s) in ${sw.elapsedMilliseconds}ms',
      );
      if (_isStale(token)) {
        Logger.debug('AudioPlayer.loadAndPlay: token $token stale, aborting');
        return;
      }

      _queue
        ..clear()
        ..addAll(resolved);
      _recoveryAttempts.clear();

      final startId = resolved[start.clamp(0, resolved.length - 1)].id;
      var srcIndex = await _buildAndSetSources(initialQueueIndex: start);
      if (srcIndex < 0) {
        // Nothing resolved to a playable URL. A genuinely locked track is the
        // UI's job (lock icon / unlock modal) — don't show a scary toast for
        // it. Otherwise this is almost always a transient/cold-start failure,
        // so re-resolve once before giving up.
        final startTrack = resolved[start.clamp(0, resolved.length - 1)];
        if (_looksLocked(startTrack)) {
          Logger.info(
            'AudioPlayer.loadAndPlay: start track ${startTrack.id} is locked — leaving to unlock UI',
          );
          return;
        }
        Logger.warning(
          'AudioPlayer.loadAndPlay: no playable sources (${_resolveFailure[startId] ?? 'unknown'}) — retrying resolution once',
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (_isStale(token)) return;
        final retried = await _resolveTracks(tracks);
        if (_isStale(token)) return;
        _queue
          ..clear()
          ..addAll(retried);
        srcIndex = await _buildAndSetSources(initialQueueIndex: start);
        if (srcIndex < 0) {
          _emitError(_messageForFailure(_resolveFailure[startId]));
          return;
        }
      }
      if (_isStale(token)) {
        Logger.debug('AudioPlayer.loadAndPlay: token $token stale after set');
        return;
      }

      Logger.info(
        'AudioPlayer.loadAndPlay: sources set, starting playback at source=$srcIndex',
      );
      _safePlay();
    } catch (e, st) {
      Logger.error('AudioPlayer.loadAndPlay failed', e, st);
      _emitError('Couldn’t start playback. Please try again.');
    }
  }

  /// (Re)builds the player's audio-source list from the current [_queue] and
  /// hands it to just_audio. Keeps the queue⟷source index maps in sync.
  /// Returns the source index that maps to [initialQueueIndex] (the nearest
  /// playable one), or -1 when nothing in the queue is playable.
  Future<int> _buildAndSetSources({
    required int initialQueueIndex,
    Duration? initialPosition,
  }) async {
    _sourceToQueue.clear();
    _queueToSource = List<int?>.filled(_queue.length, null);

    final sources = <AudioSource>[];
    var skipped = 0;
    for (var i = 0; i < _queue.length; i++) {
      final t = _queue[i];
      final url = (t.audioUrl ?? '').trim();
      if (url.isEmpty) {
        skipped++;
        final reason = _resolveFailure[t.id] ??
            (_looksLocked(t) ? 'track is locked' : 'no stream URL');
        Logger.warning(
          'AudioPlayer: queue[$i] "${t.id}" excluded from playback — $reason',
        );
        continue;
      }
      final parsed = Uri.tryParse(url);
      if (parsed == null) {
        skipped++;
        Logger.warning('AudioPlayer: queue[$i] "${t.id}" has an unparseable URL');
        continue;
      }
      _queueToSource[i] = sources.length;
      _sourceToQueue.add(i);
      sources.add(AudioSource.uri(parsed, tag: t.toMediaItem()));
    }

    Logger.info(
      'AudioPlayer: built ${sources.length} source(s), skipped $skipped of ${_queue.length}',
    );

    if (sources.isEmpty) {
      // Don't surface a message here — the caller decides whether to retry
      // (transient failure) or stay quiet (locked track handled by the UI).
      Logger.error('AudioPlayer: no playable sources after resolve');
      return -1;
    }

    final clampedQueueIndex = initialQueueIndex.clamp(0, _queue.length - 1);
    final srcIndex = _queueToSource[clampedQueueIndex] ?? 0;

    // No explicit _player.stop() — setAudioSources cleanly replaces the source
    // and is faster/safer than stop()→set. preload defaults to true so the
    // next source is buffered ahead in the background.
    await _player.setAudioSources(
      sources,
      initialIndex: srcIndex,
      initialPosition: initialPosition ?? Duration.zero,
    );
    return srcIndex;
  }

  /// Resolves any tracks that arrived without an [Track.audioUrl] using the
  /// wired resolver. Runs concurrently so a 10-track queue waits on the slowest
  /// single lookup, not the sum. Each lookup is guarded so one failure never
  /// sinks the batch; a track with no resolvable URL is kept in the queue
  /// (visible) but later excluded from the audio sources.
  Future<List<Track>> _resolveTracks(List<Track> tracks) async {
    final resolver = _streamUrlResolver;
    return Future.wait(
      tracks.map((t) async {
        final url = (t.audioUrl ?? '').trim();
        if (url.isNotEmpty) {
          _resolveFailure.remove(t.id);
          return t;
        }
        if (resolver == null) {
          _resolveFailure[t.id] = 'no stream-URL resolver wired';
          return t;
        }
        if (t.id.trim().isEmpty) {
          _resolveFailure[t.id] = 'track has no id';
          return t;
        }
        try {
          final fetched = (await resolver(t.id)).trim();
          if (fetched.isEmpty) {
            _resolveFailure[t.id] = 'backend returned 200 but no playable URL';
            Logger.warning('AudioPlayer: resolver returned empty URL for ${t.id}');
            return t;
          }
          _resolveFailure.remove(t.id);
          Logger.debug('AudioPlayer: resolved ${t.id} -> ${_hostOf(fetched)}');
          return t.copyWith(audioUrl: fetched);
        } on ApiRequestException catch (e) {
          _resolveFailure[t.id] = 'HTTP ${e.statusCode ?? '?'}: ${e.message}';
          Logger.warning(
            'AudioPlayer: stream resolve failed for ${t.id}: HTTP ${e.statusCode} — ${e.message}',
          );
          return t;
        } catch (e, st) {
          _resolveFailure[t.id] = e.toString();
          Logger.warning('AudioPlayer: stream resolve error for ${t.id}: $e');
          Logger.debug(st.toString());
          return t;
        }
      }),
    );
  }

  /// Fires play without awaiting: just_audio's `play()` future only completes
  /// when playback STOPS, so awaiting it would block. We still capture any
  /// load/playback error it throws instead of dropping it.
  void _safePlay() {
    _player.play().catchError((Object e, StackTrace st) {
      Logger.error('AudioPlayer: play() error', e, st);
      unawaited(_recoverCurrent(e));
    });
  }

  Future<void> play() async {
    _safePlay();
  }

  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      _safePlay();
    }
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> previous() async {
    final pos = _player.position;
    if (pos.inSeconds > 3 || !_player.hasPrevious) {
      await _player.seek(Duration.zero);
      return;
    }
    await _player.seekToPrevious();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  /// Jumps to the given QUEUE index (carousel/queue-sheet position) and starts
  /// that track from the beginning. Translates to the player's source index;
  /// if the queue track is locked/unplayable there's no source to jump to.
  Future<void> seekToIndex(int queueIndex) async {
    if (_queue.isEmpty) return;
    if (queueIndex < 0 || queueIndex >= _queue.length) return;
    final srcIdx =
        queueIndex < _queueToSource.length ? _queueToSource[queueIndex] : null;
    if (srcIdx == null) {
      Logger.info(
        'AudioPlayer.seekToIndex: queue=$queueIndex is not playable (locked) — ignoring',
      );
      return;
    }
    Logger.info('AudioPlayer.seekToIndex: queue=$queueIndex -> source=$srcIdx');
    await _player.seek(Duration.zero, index: srcIdx);
    _safePlay();
  }

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> setShuffle(bool enabled) async {
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> clear() async {
    await _player.stop();
    _queue.clear();
    _sourceToQueue.clear();
    _queueToSource = [];
    _recoveryAttempts.clear();
  }

  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _errorController.close();
    await _player.dispose();
  }

  // ---------------------------------------------------------------------------
  // Error monitoring + recovery
  // ---------------------------------------------------------------------------

  void _attachErrorMonitor() {
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        Logger.error('AudioPlayer: playbackEvent error', e, st);
        unawaited(_recoverCurrent(e));
      },
    );
  }

  /// Attempts to recover the currently positioned track after a playback/load
  /// error — most often an expired Azure SAS URL (valid ~1h) returning 403.
  /// Re-resolves the stream URL once and resumes at the same position.
  Future<void> _recoverCurrent(Object error) async {
    if (_recovering) return;
    final resolver = _streamUrlResolver;
    final qIdx = currentQueueIndex;
    if (resolver == null || qIdx == null || qIdx < 0 || qIdx >= _queue.length) {
      _emitError('Couldn’t play this track.');
      return;
    }
    final track = _queue[qIdx];
    final id = track.id.trim();
    if (id.isEmpty) {
      _emitError('Couldn’t play this track.');
      return;
    }
    if (_recoveryAttempts.contains(id)) {
      Logger.warning('AudioPlayer: recovery already attempted for $id — giving up');
      _emitError('Couldn’t load this track. Please try again.');
      return;
    }

    _recovering = true;
    _recoveryAttempts.add(id);
    final token = ++_loadToken;
    final position = _player.position;
    try {
      Logger.warning(
        'AudioPlayer: recovering $id (re-resolving stream URL after error: $error)',
      );
      final fresh = (await resolver(id)).trim();
      if (_isStale(token)) return;
      if (fresh.isEmpty) {
        _emitError('Couldn’t load this track. Please try again.');
        return;
      }
      _queue[qIdx] = track.copyWith(audioUrl: fresh);
      final srcIndex = await _buildAndSetSources(
        initialQueueIndex: qIdx,
        initialPosition: position,
      );
      if (srcIndex < 0 || _isStale(token)) return;
      _safePlay();
      Logger.success('AudioPlayer: recovery succeeded for $id');
    } catch (e, st) {
      Logger.error('AudioPlayer: recovery failed for $id', e, st);
      _emitError('Couldn’t load this track. Please try again.');
    } finally {
      _recovering = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Audio session (focus / interruptions / becoming-noisy)
  // ---------------------------------------------------------------------------

  /// Subscribes (once) to OS interruption + becoming-noisy events so playback
  /// behaves like a real music app: ducks/pauses for calls & other apps, and
  /// pauses when headphones are unplugged. The session itself is configured in
  /// `main()`.
  Future<void> _wireSession() async {
    if (_sessionWired) return;
    _sessionWired = true;
    try {
      final session = await AudioSession.instance;
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (_player.playing) {
                _interruptedByOs = true;
                _player.pause();
              }
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              if (_interruptedByOs) {
                _interruptedByOs = false;
                _safePlay();
              }
              break;
            case AudioInterruptionType.unknown:
              _interruptedByOs = false;
              break;
          }
        }
      });
      session.becomingNoisyEventStream.listen((_) {
        Logger.info('AudioPlayer: becoming noisy (output unplugged) — pausing');
        _player.pause();
      });
    } catch (e, st) {
      // Never let session wiring break playback; just log it.
      _sessionWired = false;
      Logger.warning('AudioPlayer: audio session wiring failed: $e');
      Logger.debug(st.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isStale(int token) => token != _loadToken;

  /// A track the backend will refuse to stream (returns ContentNotUnlocked).
  /// The player UI shows the lock icon / unlock modal for these, so we never
  /// toast a generic "can't play" message for them.
  bool _looksLocked(Track t) => !t.isUnlocked && t.unlockCostCoins > 0;

  /// Turns a resolve-failure reason into a user-friendly toast message.
  String _messageForFailure(String? reason) {
    final r = reason ?? '';
    if (r.contains('HTTP 401') || r.contains('HTTP 403')) {
      return 'Your session expired. Please sign in again.';
    }
    if (r.contains('200 but no playable URL')) {
      return 'This track isn’t available right now.';
    }
    // 5xx / timeout / network — almost always the backend warming up.
    return 'Couldn’t load this track. Please try again in a moment.';
  }

  void _emitError(String message) {
    Logger.warning('AudioPlayer: surfacing error to UI: $message');
    if (!_errorController.isClosed) _errorController.add(message);
  }

  String _hostOf(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host.isNotEmpty == true ? uri!.host : '<unknown-host>';
  }
}
