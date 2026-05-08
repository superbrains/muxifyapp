import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muxify/core/services/audio_player_service.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';

/// UI-facing wrapper around [AudioPlayerService]. Subscribes to the player's
/// streams once and rebroadcasts the bits widgets actually need so they don't
/// each have to wire StreamBuilders.
class AudioProvider extends ChangeNotifier {
  AudioProvider({
    AudioPlayerService? service,
    ArtistProfileProvider? streamUrlProvider,
  }) : _service = service ?? AudioPlayerService.instance {
    if (streamUrlProvider != null) {
      _service.setStreamUrlResolver(streamUrlProvider.getTrackStreamUrl);
    }
    _bind();
  }

  final AudioPlayerService _service;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<LoopMode>? _loopSub;
  StreamSubscription<bool>? _shuffleSub;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int? _currentIndex;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffled = false;

  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  LoopMode get loopMode => _loopMode;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _loopMode != LoopMode.off;
  List<Track> get queue => _service.queue;
  Track? get currentTrack => _service.currentTrack;
  bool get hasActiveTrack => _service.hasActiveTrack;

  /// True when the provider is showing a track the [MusicPlayerScreen] should
  /// claim. Compared by id so re-entering the route with the same trackId
  /// doesn't restart playback.
  bool isCurrent(String? trackId) {
    if (trackId == null || trackId.isEmpty) return false;
    return currentTrack?.id == trackId;
  }

  void _bind() {
    _stateSub = _service.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    _positionSub = _service.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
    _durationSub = _service.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });
    _indexSub = _service.currentIndexStream.listen((i) {
      _currentIndex = i;
      notifyListeners();
    });
    _loopSub = _service.loopModeStream.listen((m) {
      _loopMode = m;
      notifyListeners();
    });
    _shuffleSub = _service.shuffleModeEnabledStream.listen((s) {
      _isShuffled = s;
      notifyListeners();
    });
  }

  Future<void> loadAndPlay(List<Track> tracks, {int startIndex = 0}) {
    return _service.loadAndPlay(tracks, startIndex: startIndex);
  }

  /// Convenience for callers that have a single track and want to replace the
  /// queue with just that track.
  Future<void> playSingle(Track track) {
    return _service.loadAndPlay([track]);
  }

  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();
  Future<void> togglePlayPause() => _service.togglePlayPause();
  Future<void> next() => _service.next();
  Future<void> previous() => _service.previous();
  Future<void> seek(Duration position) => _service.seek(position);
  Future<void> setShuffle(bool enabled) => _service.setShuffle(enabled);

  Future<void> toggleShuffle() => _service.setShuffle(!_isShuffled);

  Future<void> toggleRepeat() {
    final next = switch (_loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    return _service.setLoopMode(next);
  }

  Future<void> clear() => _service.clear();

  // Suppress lint for the held but otherwise unread index — it drives
  // notifyListeners() so callers re-read currentTrack.
  // ignore: unused_element
  int? get currentIndex => _currentIndex;

  @override
  void dispose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _indexSub?.cancel();
    _loopSub?.cancel();
    _shuffleSub?.cancel();
    super.dispose();
  }
}
