import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/celebration_painter.dart';

/// A celebratory, full-screen "firework splash" that plays after content is
/// unlocked (a song, a video — anything).
///
/// Mirrors [GiftCelebrationOverlay], reusing the same shared [CelebrationPainter]
/// engine, but the centrepiece is the unlocked item's cover art in a rounded
/// card with an "unlocked" padlock badge plus a caption + title, instead of a
/// gift emoji.
///
/// Drop it on top of everything via [UnlockCelebrationOverlay.show]; it inserts
/// itself into the root [Overlay] (above any dialog / bottom sheet), plays once,
/// then removes itself and fires [onComplete].
class UnlockCelebrationOverlay extends StatefulWidget {
  /// Cover art of the unlocked item: an `assets/...` path, a Muxify API proxy
  /// path/URL, or a public CDN URL. Empty -> a branded padlock fallback.
  final String coverImage;

  /// Main line, e.g. the track / video title. Empty -> a generic substitute.
  final String title;

  /// Secondary line, e.g. the artist. Hidden when empty.
  final String subtitle;

  /// Short caption shown (uppercased) above the title, e.g. "SONG UNLOCKED".
  final String caption;

  final VoidCallback? onCompleted;

  const UnlockCelebrationOverlay({
    super.key,
    required this.coverImage,
    required this.title,
    this.subtitle = '',
    this.caption = 'Unlocked',
    this.onCompleted,
  });

  /// Inserts the celebration into the root overlay so it floats above any modal
  /// or bottom sheet. [onComplete] runs once the animation finishes (after the
  /// overlay has removed itself).
  static void show(
    BuildContext context, {
    required String coverImage,
    required String title,
    String subtitle = '',
    String caption = 'Unlocked',
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => UnlockCelebrationOverlay(
        coverImage: coverImage,
        title: title,
        subtitle: subtitle,
        caption: caption,
        onCompleted: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<UnlockCelebrationOverlay> createState() =>
      _UnlockCelebrationOverlayState();
}

class _UnlockCelebrationOverlayState extends State<UnlockCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2400);

  late final AnimationController _controller;
  late final List<Burst> _bursts;
  late final List<Confetti> _confetti;
  late final List<Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _bursts = CelebrationParticles.buildBursts(rng);
    _confetti = CelebrationParticles.buildConfetti(rng);
    _sparkles = CelebrationParticles.buildSparkles(rng);

    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });

    // A little celebratory kick.
    HapticFeedback.mediumImpact();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) =>
      CelebrationParticles.seg(t, a, b);

  String get _displayTitle =>
      widget.title.trim().isEmpty ? 'this item' : widget.title.trim();

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Positioned.fill(
      // Swallow taps so the user can't disturb anything mid-celebration.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;

            // Centre card "pop": overshoot in, hold, then expand + fade out.
            final scaleIn = Curves.easeOutBack.transform(_seg(t, 0.0, 0.20));
            final scaleOut = 1.0 + _seg(t, 0.72, 1.0) * 0.7;
            final popScale = scaleIn * scaleOut;
            final popOpacity =
                (_seg(t, 0.0, 0.10) * (1.0 - _seg(t, 0.78, 1.0)))
                    .clamp(0.0, 1.0);
            final glowOpacity =
                popOpacity * (0.55 + 0.45 * math.sin(t * math.pi));

            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Fireworks, confetti, flash + scrim across the full screen.
                CustomPaint(
                  size: screen,
                  painter: CelebrationPainter(
                    progress: t,
                    bursts: _bursts,
                    confetti: _confetti,
                    sparkles: _sparkles,
                  ),
                ),

                // The unlocked cover art popping in the centre with a glow halo.
                Center(
                  child: Opacity(
                    opacity: popOpacity,
                    child: Transform.scale(
                      scale: popScale,
                      child: _centrepiece(screen, glowOpacity),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _centrepiece(Size screen, double glowOpacity) {
    return Container(
      // A soft radial glow behind the card keeps the "pop" energy of the gift
      // celebration.
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85 * glowOpacity),
            const Color(0xFFFFD60A).withValues(alpha: 0.40 * glowOpacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rounded-square cover card with an unlocked padlock badge.
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 132,
                    height: 132,
                    color: AppColors.glassyDark,
                    child: _coverImage(widget.coverImage),
                  ),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.artistProfileGreen,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.caption.trim().toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.artistProfileGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screen.width * 0.7),
            child: Text(
              _displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screen.width * 0.7),
              child: Text(
                widget.subtitle.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _coverImage(String pathOrUrl) {
    final t = pathOrUrl.trim();
    if (t.isEmpty) return _fallback();
    if (t.toLowerCase().startsWith('assets/')) {
      return Image.asset(
        t,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return AuthNetworkImage(
      path: t,
      fit: BoxFit.cover,
      placeholder: _fallback(),
      errorWidget: _fallback(),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.glassyDark,
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock_open_rounded,
          color: Colors.white,
          size: 48,
        ),
      );
}
