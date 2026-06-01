import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/celebration_painter.dart';

/// A celebratory, full-screen "firework splash" that plays after a gift is sent.
///
/// Pure-Flutter (no extra packages): the shared [CelebrationPainter] renders a
/// quick white flash, several staggered firework bursts, falling confetti and
/// twinkling sparkles, while the gifted icon "pops" in the centre with a glowing
/// halo.
///
/// Drop it on top of everything via [GiftCelebrationOverlay.show]; it inserts
/// itself into the root [Overlay] (above any dialog), plays once, then removes
/// itself and fires [onComplete] — the natural place to dismiss the GIFTBOX
/// dialog and refresh balances.
class GiftCelebrationOverlay extends StatefulWidget {
  final GiftItem gift;
  final VoidCallback? onCompleted;

  const GiftCelebrationOverlay({
    super.key,
    required this.gift,
    this.onCompleted,
  });

  /// Inserts the celebration into the root overlay so it floats above the
  /// GIFTBOX dialog. [onComplete] runs once the animation finishes (after the
  /// overlay has removed itself).
  static void show(
    BuildContext context, {
    required GiftItem gift,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => GiftCelebrationOverlay(
        gift: gift,
        onCompleted: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<GiftCelebrationOverlay> createState() => _GiftCelebrationOverlayState();
}

class _GiftCelebrationOverlayState extends State<GiftCelebrationOverlay>
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

            // Centre icon "pop": overshoot in, hold, then expand + fade out.
            final scaleIn = Curves.easeOutBack.transform(_seg(t, 0.0, 0.20));
            final scaleOut = 1.0 + _seg(t, 0.72, 1.0) * 0.7;
            final popScale = scaleIn * scaleOut;
            final popOpacity =
                (_seg(t, 0.0, 0.10) * (1.0 - _seg(t, 0.78, 1.0)))
                    .clamp(0.0, 1.0);
            final glowOpacity =
                popOpacity * (0.55 + 0.45 * math.sin(t * math.pi));

            // StackFit.expand + an explicit painter size guarantees the
            // fireworks fill the whole screen — without it the Stack would
            // shrink to the 132px icon and the effect would be invisible.
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

                // The gifted icon popping in the centre with a glow halo.
                Center(
                  child: Opacity(
                    opacity: popOpacity,
                    child: Transform.scale(
                      scale: popScale,
                      child: Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white
                                  .withValues(alpha: 0.85 * glowOpacity),
                              const Color(0xFFFFD60A)
                                  .withValues(alpha: 0.45 * glowOpacity),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 86,
                          height: 86,
                          child: _giftIcon(widget.gift.emojiImage),
                        ),
                      ),
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

  Widget _giftIcon(String pathOrUrl) {
    final t = pathOrUrl.trim();
    if (t.isEmpty) {
      return const Icon(Icons.card_giftcard, color: Colors.white, size: 64);
    }
    if (t.toLowerCase().startsWith('assets/')) {
      return Image.asset(t, fit: BoxFit.contain);
    }
    return AuthNetworkImage(
      path: t,
      fit: BoxFit.contain,
      errorWidget: const Icon(Icons.card_giftcard, color: Colors.white),
    );
  }
}
