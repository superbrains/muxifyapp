import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/services/audio_player_service.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/music_player/providers/lyrics_provider.dart';

/// Apple-Music-style lyrics surface that drops in over the player artwork.
/// Rendered behind the playback controls so the user can keep scrubbing,
/// liking, and gifting while reading along.
///
/// Subscribes directly to [AudioPlayerService.instance.positionStream] rather
/// than reading [AudioProvider.position]; the provider's notifyListeners is
/// throttled by Flutter's rebuild pipeline and the lyric scroll visibly
/// stutters when fed from there.
class LyricsOverlay extends StatefulWidget {
  const LyricsOverlay({super.key});

  @override
  State<LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends State<LyricsOverlay> {
  final LyricController _controller = LyricController();
  StreamSubscription<Duration>? _positionSub;

  String? _loadedTrackId;
  String? _loadedLrcSignature;
  bool _hasLoadedLyric = false;

  @override
  void initState() {
    super.initState();
    _positionSub = AudioPlayerService.instance.positionStream.listen((p) {
      if (!mounted || !_hasLoadedLyric) return;
      _controller.setProgress(p);
    });

    _controller.setOnTapLineCallback((Duration position) {
      // ignore: use_build_context_synchronously
      context.read<AudioProvider>().seek(position);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _ensureLoaded(LyricsProvider lyrics, String? trackId) {
    final id = (trackId ?? '').trim();
    if (id.isEmpty) return;
    if (_loadedTrackId == id) {
      _syncControllerToProvider(lyrics);
      return;
    }
    _loadedTrackId = id;
    _hasLoadedLyric = false;
    _loadedLrcSignature = null;
    // Defer to after the current frame: this is called from build(), and
    // calling notifyListeners synchronously inside build is forbidden.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      lyrics.loadFor(id);
    });
  }

  void _syncControllerToProvider(LyricsProvider lyrics) {
    if (lyrics.status != LyricsStatus.ready) return;
    final lrc = lyrics.lrc;
    if (lrc == null) return;
    final signature = '${lrc.length}:${lrc.hashCode}';
    if (_loadedLrcSignature == signature) return;
    _loadedLrcSignature = signature;
    _controller.loadLyric(lrc);
    _hasLoadedLyric = true;
    // Seed with the current playback position so the line snaps to the
    // right spot instead of starting at the top until the next stream tick.
    _controller.setProgress(AudioPlayerService.instance.player.position);
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final lyrics = context.watch<LyricsProvider>();
    _ensureLoaded(lyrics, audio.currentTrack?.id);
    _syncControllerToProvider(lyrics);

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.padding,
                  vertical: 32.padding,
                ),
                child: _buildBody(lyrics),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LyricsProvider lyrics) {
    switch (lyrics.status) {
      case LyricsStatus.loading:
      case LyricsStatus.idle:
        return _LoadingShimmer();
      case LyricsStatus.empty:
        return const _EmptyMessage(
          text: 'Lyrics not available for this track yet.',
        );
      case LyricsStatus.error:
        return _EmptyMessage(
          text: lyrics.errorMessage ?? "Couldn't load lyrics.",
        );
      case LyricsStatus.ready:
        return LyricView(
          controller: _controller,
          width: double.infinity,
          height: double.infinity,
          style: _muxifyStyle,
        );
    }
  }
}

/// Style mirroring the existing modal: dim non-playing lines, bold-white
/// active line, left-aligned, top fade so artwork shows through at the
/// edges. Built off `default2` (the karaoke-style preset) and tweaked.
final LyricStyle _muxifyStyle = LyricStyles.default2.copyWith(
  textStyle: TextStyle(
    fontSize: 18,
    height: 1.3,
    color: Colors.white.withValues(alpha: 0.45),
    fontWeight: FontWeight.w600,
  ),
  activeStyle: const TextStyle(
    fontSize: 22,
    height: 1.3,
    color: Colors.white,
    fontWeight: FontWeight.w700,
  ),
  textAlign: TextAlign.left,
  lineGap: 18,
  contentAlignment: CrossAxisAlignment.start,
  contentPadding: const EdgeInsets.only(top: 40, left: 4, right: 4, bottom: 60),
  // Disable the gradient highlight from default2 — looks out of place over album art.
  activeHighlightGradient: null,
  activeHighlightTailGradientWidth: 0,
);

class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.18),
      highlightColor: Colors.white.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          final w = [0.85, 0.7, 0.92, 0.6, 0.78, 0.5][i];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.padding),
            child: Container(
              height: 18,
              width: MediaQuery.of(context).size.width * w * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.padding),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.specialText.copyWith(
            color: AppColors.text.withValues(alpha: 0.7),
            fontSize: 16.font,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
