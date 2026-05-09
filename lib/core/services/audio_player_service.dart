import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/audio_playback/models/track.dart';

typedef StreamUrlResolver = Future<String> Function(String trackId);

/// Singleton owning the app's only [AudioPlayer]. Survives navigation so audio
/// keeps playing across screen changes and into the background, where
/// `just_audio_background` connects this player to the OS notification and
/// lock-screen widget.
class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  final List<Track> _queue = [];
  StreamUrlResolver? _streamUrlResolver;

  AudioPlayer get player => _player;
  List<Track> get queue => List.unmodifiable(_queue);

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

  Track? get currentTrack {
    if (_queue.isEmpty) return null;
    final idx = _player.currentIndex;
    if (idx == null || idx < 0 || idx >= _queue.length) return _queue.first;
    return _queue[idx];
  }

  bool get hasActiveTrack => _queue.isNotEmpty;

  Future<void> loadAndPlay(
    List<Track> tracks, {
    int startIndex = 0,
  }) async {
    if (tracks.isEmpty) return;
    final clampedIndex = startIndex.clamp(0, tracks.length - 1);

    try {
      await _player.stop();

      final resolved = await _resolveTracks(tracks);
      _queue
        ..clear()
        ..addAll(resolved);

      final sources = <AudioSource>[];
      for (final t in resolved) {
        final url = (t.audioUrl ?? '').trim();
        if (url.isEmpty) continue;
        sources.add(
          AudioSource.uri(Uri.parse(url), tag: t.toMediaItem()),
        );
      }
      if (sources.isEmpty) {
        Logger.warning('AudioPlayerService: no playable sources after resolve');
        return;
      }

      await _player.setAudioSources(
        sources,
        initialIndex: clampedIndex.clamp(0, sources.length - 1),
      );
      await _player.play();
    } catch (e, st) {
      Logger.error('AudioPlayerService.loadAndPlay failed', e, st);
    }
  }

  /// Resolves any tracks that arrived without an [audioUrl] using the wired
  /// resolver. Tracks with no resolvable URL are kept in the queue so the
  /// caller can see them, but skipped when building audio sources.
  Future<List<Track>> _resolveTracks(List<Track> tracks) async {
    final resolver = _streamUrlResolver;
    final out = <Track>[];
    for (final t in tracks) {
      final url = (t.audioUrl ?? '').trim();
      if (url.isNotEmpty || resolver == null || t.id.trim().isEmpty) {
        out.add(t);
        continue;
      }
      try {
        final fetched = (await resolver(t.id)).trim();
        out.add(fetched.isEmpty ? t : t.copyWith(audioUrl: fetched));
      } catch (e, st) {
        Logger.warning('Stream URL resolve failed for ${t.id}: $e');
        Logger.debug(st.toString());
        out.add(t);
      }
    }
    return out;
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
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

  /// Jumps to the given queue index and restarts that track from the
  /// beginning. No-op if the index is out of range or the queue is empty.
  Future<void> seekToIndex(int index) async {
    if (_queue.isEmpty) return;
    if (index < 0 || index >= _queue.length) return;
    await _player.seek(Duration.zero, index: index);
    await _player.play();
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
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
