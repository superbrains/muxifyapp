import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Docked mini-player for the Muxify brand: glassy dark surface, brand-red
/// progress + play button, animated equalizer + marquee while playing.
/// Tapping anywhere on the bar opens the full [MusicPlayerScreen]; the
/// individual controls toggle playback / skip in place.
class PersistentMiniPlayer extends StatelessWidget {
  const PersistentMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final track = audio.currentTrack;
    if (track == null) {
      return const SizedBox.shrink();
    }

    final duration = audio.duration.inMilliseconds;
    final position = audio.position.inMilliseconds.clamp(0, duration);
    final progress = duration > 0 ? position / duration : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openFullPlayer(track),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0E0E0E)],
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandProgressLine(progress: progress.clamp(0.0, 1.0)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.padding,
                  vertical: 10.padding,
                ),
                child: Row(
                  children: [
                    _Artwork(track: track),
                    12.row,
                    if (audio.isPlaying) ...[
                      const _EqualizerBars(),
                      8.row,
                    ],
                    Expanded(child: _TitleArtist(track: track)),
                    8.row,
                    _SkipButton(
                      icon: Icons.skip_previous,
                      onTap: audio.previous,
                    ),
                    _PlayPauseButton(
                      isPlaying: audio.isPlaying,
                      onTap: audio.togglePlayPause,
                    ),
                    _SkipButton(
                      icon: Icons.skip_next,
                      onTap: audio.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullPlayer(Track track) {
    HapticFeedback.lightImpact();
    final params = <String, String>{
      'trackId': track.id,
      'title': track.title,
      'artistName': track.artist,
      'isUnlocked': track.isUnlocked.toString(),
    };
    if (track.unlockCostCoins > 0) {
      params['unlockCostCoins'] = track.unlockCostCoins.toString();
    }
    final artistId = (track.artistId ?? '').trim();
    if (artistId.isNotEmpty) params['artistId'] = artistId;
    final albumName = (track.albumName ?? '').trim();
    if (albumName.isNotEmpty) params['albumName'] = albumName;
    final artworkUrl = (track.artworkUrl ?? '').trim();
    if (artworkUrl.isNotEmpty) params['backgroundImageUrl'] = artworkUrl;
    final audioUrl = (track.audioUrl ?? '').trim();
    if (audioUrl.isNotEmpty) params['audioUrl'] = audioUrl;
    AppRouter.router.pushNamed('music-player', queryParameters: params);
  }
}

class _BrandProgressLine extends StatelessWidget {
  const _BrandProgressLine({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.border,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.white.withValues(alpha: 0.10)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.buttonColor,
                      AppColors.miniPlayerProgressEnd,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.maxWidth,
      height: 44.maxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.radius),
        child: _ArtworkImage(url: track.artworkUrl),
      ),
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final raw = (url ?? '').trim();
    if (raw.isEmpty) return const _BrandedArtworkFallback();
    final lower = raw.toLowerCase();
    final isRemote = lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        raw.startsWith('/');
    if (isRemote) {
      return AuthNetworkImage(
        path: raw,
        fit: BoxFit.cover,
        placeholder: const _BrandedArtworkFallback(),
        errorWidget: const _BrandedArtworkFallback(),
      );
    }
    return Image.asset(
      raw,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _BrandedArtworkFallback(),
    );
  }
}

class _BrandedArtworkFallback extends StatelessWidget {
  const _BrandedArtworkFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050507),
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.7),
          radius: 1.4,
          colors: [
            AppColors.buttonColor,
            Color(0xFF050507),
            AppColors.blue,
          ],
          stops: [0.0, 0.65, 1.0],
        ),
      ),
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.85,
        child: Image.asset(
          'assets/pngs/logo.png',
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _TitleArtist extends StatelessWidget {
  const _TitleArtist({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MarqueeText(
          text: track.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.font,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        2.column,
        Text(
          track.artist,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.font,
            fontWeight: FontWeight.w400,
            color: AppColors.text.withValues(alpha: 0.60),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  static const double _pixelsPerSecond = 30;
  static const double _gap = 32;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _ensureRunning(double textWidth, double maxWidth) {
    final shouldScroll = textWidth > maxWidth;
    if (!shouldScroll) {
      if (_ctrl.isAnimating) {
        _ctrl.stop();
        _ctrl.value = 0;
      }
      return;
    }
    if (_ctrl.isAnimating) return;
    final distance = textWidth + _gap;
    final ms = ((distance / _pixelsPerSecond) * 1000).round();
    _ctrl.duration = Duration(milliseconds: ms);
    _ctrl.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final textWidth = tp.width;
        final maxWidth = constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ensureRunning(textWidth, maxWidth);
        });
        if (textWidth <= maxWidth) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        final loopWidth = textWidth + _gap;
        return ClipRect(
          child: SizedBox(
            height: tp.height,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final dx = -_ctrl.value * loopWidth;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.text, style: widget.style, maxLines: 1),
                      SizedBox(width: _gap),
                      Text(widget.text, style: widget.style, maxLines: 1),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars();

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with TickerProviderStateMixin {
  static const _durationsMs = [600, 720, 840];
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _durationsMs
        .map((ms) => AnimationController(
              vsync: this,
              duration: Duration(milliseconds: ms),
            )..repeat(reverse: true))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.padding),
          child: AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, _) {
              final t = Curves.easeInOut.transform(_controllers[i].value);
              final h = 6.0 + t * 8.0;
              return Container(
                width: 2.5.maxWidth,
                height: h.maxHeight,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(1.radius),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.icon, required this.onTap});
  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: 44.maxWidth,
        height: 44.maxHeight,
        child: Icon(
          icon,
          size: 24.icon,
          color: AppColors.text.withValues(alpha: 0.80),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onTap});
  final bool isPlaying;
  final Future<void> Function() onTap;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          width: 40.maxWidth,
          height: 40.maxHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.buttonColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withValues(alpha: 0.35),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.text,
            size: 24.icon,
          ),
        ),
      ),
    );
  }
}
