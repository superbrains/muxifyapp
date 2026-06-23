import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/services/audio_player_service.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/ads/models/served_ad.dart';
import 'package:muxify/features/ads/services/ads_api_service.dart';

/// Spotify-style audio-ad interstitial.
///
/// Watches the music player; every [_tracksPerAd] track changes it asks the
/// server for an audio ad. If one is available it pauses the user's music,
/// plays the ad on its OWN player behind a non-skippable overlay (see
/// `AudioAdOverlay`), fires the impression, and resumes the music when the ad
/// finishes. The ad's own player is kept separate from the music queue so the
/// user's queue/now-playing state is never disturbed.
class AudioAdController extends ChangeNotifier {
  AudioAdController({AdsApiService? service, AudioPlayerService? music})
      : _service = service ?? AdsApiService(),
        _music = music ?? AudioPlayerService.instance {
    _trackSub = _music.currentIndexStream.listen(_onTrackChanged);
    _adStateSub = _adPlayer.playerStateStream.listen(_onAdState);
    _adPosSub = _adPlayer.positionStream.listen((_) {
      if (_active) _safeNotify();
    });
  }

  final AdsApiService _service;
  final AudioPlayerService _music;
  final AudioPlayer _adPlayer = AudioPlayer();

  /// Serve an ad once every N track changes. Tunable; deliberately conservative.
  static const int _tracksPerAd = 3;

  static const String _surface = 'Interstitial';

  StreamSubscription<int?>? _trackSub;
  StreamSubscription<PlayerState>? _adStateSub;
  StreamSubscription<Duration>? _adPosSub;

  int _changesSinceAd = 0;
  int? _lastIndex;
  bool _active = false;
  bool _starting = false;
  bool _resumeMusicAfter = false;
  ServedAd? _ad;
  bool _disposed = false;

  /// Whether an ad interstitial is currently on screen.
  bool get active => _active;

  /// The ad currently playing (null when none).
  ServedAd? get ad => _ad;

  /// Seconds left before the (non-skippable) ad audio finishes.
  int get secondsRemaining {
    final total = (_adPlayer.duration ?? Duration.zero).inSeconds;
    final pos = _adPlayer.position.inSeconds;
    if (total <= 0) return 0;
    return (total - pos).clamp(0, total);
  }

  void _onTrackChanged(int? index) {
    // Ignore the initial emission and same-index repeats.
    if (index == null || index == _lastIndex) return;
    final first = _lastIndex == null;
    _lastIndex = index;
    if (first || _active || _starting) return;

    _changesSinceAd++;
    if (_changesSinceAd >= _tracksPerAd) {
      _changesSinceAd = 0;
      unawaited(_tryPlay());
    }
  }

  Future<void> _tryPlay() async {
    // Only interrupt if the user is actually listening right now.
    if (!_music.player.playing) return;
    _starting = true;
    try {
      final ad = await _service.serve(surface: _surface, format: 'audio');
      final audio = ad?.audioUrl;
      if (ad == null || audio == null) return; // nothing eligible to play

      // Pause the user's music; remember to resume it afterwards.
      _resumeMusicAfter = _music.player.playing;
      await _music.pause();

      // Resolve + authenticate the proxied audio URL for just_audio.
      final fullUrl = ApiConstants.resolvePublicUrl(audio);
      final token = (await LocalStorageService.getAccessToken())?.trim() ?? '';
      final headers = token.isEmpty
          ? null
          : <String, String>{
              ApiConstants.authorization: '${ApiConstants.bearer} $token',
            };
      await _adPlayer.setAudioSources([
        AudioSource.uri(Uri.parse(fullUrl), headers: headers),
      ]);

      _ad = ad;
      _active = true;
      _safeNotify();

      // Impression fires as the ad begins (billed server-side, best-effort).
      unawaited(_service.recordImpression(
        campaignId: ad.campaignId,
        impressionToken: ad.impressionToken,
        surface: ad.surface,
      ));

      await _adPlayer.play();
    } catch (e, st) {
      Logger.error('Audio ad interstitial failed', e, st);
      await _endAd();
    } finally {
      _starting = false;
    }
  }

  void _onAdState(PlayerState state) {
    if (state.processingState == ProcessingState.completed) {
      unawaited(_endAd());
    }
  }

  /// Records the click for the current ad (best-effort), e.g. on "Learn more".
  Future<void> registerClick() async {
    final ad = _ad;
    if (ad == null) return;
    await _service.recordClick(
      campaignId: ad.campaignId,
      impressionToken: ad.impressionToken,
      surface: ad.surface,
    );
  }

  Future<void> _endAd() async {
    if (!_active && _ad == null) return;
    _active = false;
    _ad = null;
    _safeNotify();

    try {
      await _adPlayer.stop();
    } catch (_) {}

    if (_resumeMusicAfter) {
      _resumeMusicAfter = false;
      try {
        await _music.play();
      } catch (_) {}
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _trackSub?.cancel();
    _adStateSub?.cancel();
    _adPosSub?.cancel();
    _adPlayer.dispose();
    super.dispose();
  }
}
