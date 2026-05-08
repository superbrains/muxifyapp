import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';

/// Muxify-branded fallback used when a track has no cover art and no artist
/// avatar to fall back to. Pure Flutter primitives — no asset bundle cost.
///
/// The composition layers, back to front:
///   1. Deep-warm base
///   2. Ember-red radial gradient (top-left) + electric-teal radial gradient
///      (bottom-right), overlapping into a subtle purple band
///   3. Concentric pulse rings + equalizer-bar silhouette painted via
///      [_BrandMotifPainter]
///   4. "MUXIFY" wordmark, low-opacity, vertically positioned ~78% down
class MuxifyBrandedBackground extends StatelessWidget {
  const MuxifyBrandedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF050507)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6, -0.7),
              radius: 1.2,
              colors: [
                Color(0xB36E1E1E), // headerGradient @ 70%
                Color(0x80EA4335), // buttonColor @ 50%
                Color(0x00000000),
              ],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.7, 0.8),
              radius: 1.4,
              colors: [
                Color(0x9906A0B5), // blue @ 60%
                Color(0x66005D61), // statisticsHeaderGradient @ 40%
                Color(0x00000000),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _BrandMotifPainter(), size: Size.infinite),
        Align(
          alignment: const Alignment(0, 0.56),
          child: Text(
            'MUXIFY',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMotifPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintPulseRings(canvas, size);
    _paintEqualizerBars(canvas, size);
  }

  void _paintPulseRings(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxDimension = math.max(size.width, size.height);
    const ringConfigs = <_RingConfig>[
      _RingConfig(radiusFactor: 0.18, opacity: 0.18),
      _RingConfig(radiusFactor: 0.34, opacity: 0.10),
      _RingConfig(radiusFactor: 0.56, opacity: 0.05),
    ];

    for (final ring in ringConfigs) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.toggleSelected.withValues(alpha: ring.opacity);
      canvas.drawCircle(center, maxDimension * ring.radiusFactor, paint);
    }
  }

  void _paintEqualizerBars(Canvas canvas, Size size) {
    const barCount = 48;
    const seed = 7;
    final rng = math.Random(seed);
    final bandTop = size.height * 0.82;
    final bandHeight = size.height * 0.18;
    final barWidth = size.width / (barCount * 1.6);
    final gap = (size.width - barWidth * barCount) / (barCount + 1);

    final paint = Paint()
      ..color = AppColors.text.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < barCount; i++) {
      final heightFactor = 0.2 + rng.nextDouble() * 0.8;
      final barHeight = bandHeight * heightFactor;
      final left = gap + i * (barWidth + gap);
      final top = bandTop + (bandHeight - barHeight);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BrandMotifPainter oldDelegate) => false;
}

class _RingConfig {
  const _RingConfig({required this.radiusFactor, required this.opacity});
  final double radiusFactor;
  final double opacity;
}
