import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared, pure-Flutter "firework splash" engine used by the gift and unlock
/// celebrations.
///
/// It owns everything that is identical between the two: the vibrant palette,
/// the particle/confetti/sparkle data, the generators that build a randomised
/// set of them, and the [CelebrationPainter] that renders a white flash, several
/// staggered firework bursts, falling confetti, twinkling sparkles and a gentle
/// dark scrim across the whole screen.
///
/// Each overlay supplies only its own centrepiece (the icon / cover art that
/// "pops" in the middle); the surrounding pyrotechnics come from here.
class CelebrationParticles {
  CelebrationParticles._();

  /// Vibrant "Afro-Digital Pulse" palette for particles + confetti.
  static const List<Color> palette = [
    Color(0xFFFF4D6D), // pink-red
    Color(0xFFFFD60A), // gold
    Color(0xFF7B2FF7), // electric purple
    Color(0xFF00E5FF), // cyan
    Color(0xFFFF7A00), // orange
    Color(0xFF39FF14), // neon green
  ];

  /// Maps a global timeline value [t] into a 0..1 progress for the segment
  /// `[a, b]`, clamped at both ends.
  static double seg(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  static List<Burst> buildBursts(math.Random rng) {
    Color color() => palette[rng.nextInt(palette.length)];

    Burst makeBurst({
      required Offset origin,
      required double startT,
      required int count,
      required double spread,
      bool multicolor = true,
    }) {
      final base = color();
      final particles = List.generate(count, (i) {
        final angle = (i / count) * math.pi * 2 + rng.nextDouble() * 0.3;
        return Particle(
          angle: angle,
          speed: spread * (0.55 + rng.nextDouble() * 0.45),
          size: 2.2 + rng.nextDouble() * 2.8,
          color: multicolor ? color() : base,
          sparkle: rng.nextDouble() < 0.25,
        );
      });
      return Burst(
        origin: origin,
        startT: startT,
        duration: 0.55,
        particles: particles,
      );
    }

    return [
      // Big central burst, slightly delayed so the centrepiece pops first.
      makeBurst(
        origin: const Offset(0.5, 0.46),
        startT: 0.06,
        count: 34,
        spread: 0.42,
      ),
      // Scattered secondary bursts around the upper half.
      makeBurst(
        origin: Offset(0.24 + rng.nextDouble() * 0.08, 0.30),
        startT: 0.20,
        count: 24,
        spread: 0.30,
      ),
      makeBurst(
        origin: Offset(0.70 + rng.nextDouble() * 0.08, 0.34),
        startT: 0.28,
        count: 24,
        spread: 0.30,
      ),
      makeBurst(
        origin: Offset(0.40 + rng.nextDouble() * 0.10, 0.62),
        startT: 0.40,
        count: 22,
        spread: 0.28,
      ),
      makeBurst(
        origin: Offset(0.62 + rng.nextDouble() * 0.08, 0.58),
        startT: 0.50,
        count: 22,
        spread: 0.28,
      ),
    ];
  }

  static List<Confetti> buildConfetti(math.Random rng) {
    return List.generate(46, (i) {
      return Confetti(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.25,
        width: 6 + rng.nextDouble() * 6,
        height: 9 + rng.nextDouble() * 8,
        color: palette[rng.nextInt(palette.length)],
        rotation: rng.nextDouble() * math.pi * 2,
        rotationSpeed: (rng.nextDouble() - 0.5) * 14,
        swayAmplitude: 0.02 + rng.nextDouble() * 0.05,
        swayFrequency: 1.5 + rng.nextDouble() * 2.5,
      );
    });
  }

  static List<Sparkle> buildSparkles(math.Random rng) {
    return List.generate(24, (i) {
      return Sparkle(
        position: Offset(rng.nextDouble(), rng.nextDouble() * 0.85),
        startT: rng.nextDouble() * 0.7,
        maxRadius: 3 + rng.nextDouble() * 4,
        color: palette[rng.nextInt(palette.length)],
      );
    });
  }
}

/// A single firework burst: a set of [particles] flung from [origin]
/// (fractions of the screen) starting at [startT] on the global timeline.
class Burst {
  final Offset origin;
  final double startT;
  final double duration;
  final List<Particle> particles;

  const Burst({
    required this.origin,
    required this.startT,
    required this.duration,
    required this.particles,
  });
}

class Particle {
  final double angle;
  final double speed; // fraction of the shortest screen side
  final double size;
  final Color color;
  final bool sparkle;

  const Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.sparkle,
  });
}

class Confetti {
  final double x; // 0..1 horizontal start
  final double delay; // 0..1 timeline delay before it starts falling
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double swayAmplitude;
  final double swayFrequency;

  const Confetti({
    required this.x,
    required this.delay,
    required this.width,
    required this.height,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
  });
}

class Sparkle {
  final Offset position; // 0..1 fractions
  final double startT;
  final double maxRadius;
  final Color color;

  const Sparkle({
    required this.position,
    required this.startT,
    required this.maxRadius,
    required this.color,
  });
}

class CelebrationPainter extends CustomPainter {
  final double progress;
  final List<Burst> bursts;
  final List<Confetti> confetti;
  final List<Sparkle> sparkles;

  CelebrationPainter({
    required this.progress,
    required this.bursts,
    required this.confetti,
    required this.sparkles,
  });

  double _seg(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;
    final shortest = size.shortestSide;

    _paintScrim(canvas, size, t);
    _paintFlash(canvas, size, t);
    _paintBursts(canvas, size, shortest, t);
    _paintConfetti(canvas, size, t);
    _paintSparkles(canvas, size, t);
  }

  void _paintScrim(Canvas canvas, Size size, double t) {
    // A gentle dark scrim that fades in then out so colours pop, without
    // fully hiding the dialog behind it.
    final alpha = 0.34 * math.sin(t * math.pi);
    if (alpha <= 0) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: alpha.clamp(0.0, 1.0)),
    );
  }

  void _paintFlash(Canvas canvas, Size size, double t) {
    final f = 1.0 - _seg(t, 0.0, 0.14);
    if (f <= 0) return;
    final center = Offset(size.width * 0.5, size.height * 0.46);
    final radius = size.shortestSide * (0.2 + (1 - f) * 0.6);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9 * f),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _paintBursts(Canvas canvas, Size size, double shortest, double t) {
    for (final burst in bursts) {
      final lp = _seg(t, burst.startT, burst.startT + burst.duration);
      if (lp <= 0 || lp >= 1) continue;

      final origin =
          Offset(burst.origin.dx * size.width, burst.origin.dy * size.height);
      // Ease-out radial expansion + a little gravity droop.
      final distFrac = 1 - math.pow(1 - lp, 2).toDouble();
      final gravity = 0.14 * shortest * lp * lp;
      final alpha =
          (math.min(lp * 6, 1.0) * (1 - lp)).clamp(0.0, 1.0).toDouble();

      for (final p in burst.particles) {
        final dir = Offset(math.cos(p.angle), math.sin(p.angle));
        final pos = origin +
            dir * (p.speed * shortest * distFrac) +
            Offset(0, gravity);
        final radius = p.size * (1 - 0.4 * lp);
        final color = p.color.withValues(alpha: alpha);

        // Soft glow halo.
        canvas.drawCircle(
          pos,
          radius * 2.4,
          Paint()..color = p.color.withValues(alpha: alpha * 0.22),
        );

        // Trailing streak back toward the origin.
        final tail = pos - dir * (radius * 3 + p.speed * shortest * 0.05);
        canvas.drawLine(
          tail,
          pos,
          Paint()
            ..color = color.withValues(alpha: alpha * 0.5)
            ..strokeWidth = radius * 0.7
            ..strokeCap = StrokeCap.round,
        );

        if (p.sparkle) {
          _drawStar(canvas, pos, radius * 1.8, color);
        } else {
          canvas.drawCircle(pos, radius, Paint()..color = color);
        }
      }
    }
  }

  void _paintConfetti(Canvas canvas, Size size, double t) {
    for (final c in confetti) {
      final lp = _seg(t, c.delay, 1.0);
      if (lp <= 0) continue;
      final fade = 1.0 - _seg(t, 0.85, 1.0);
      if (fade <= 0) continue;

      final y = (-0.1 + lp * 1.25) * size.height;
      final sway =
          math.sin(lp * c.swayFrequency * math.pi * 2) * c.swayAmplitude;
      final x = (c.x + sway) * size.width;
      final angle = c.rotation + lp * c.rotationSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      final paint = Paint()
        ..color = c.color.withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: c.width,
          // Squash vertically as it "tumbles" for a 3D feel.
          height: c.height * (0.4 + 0.6 * (0.5 + 0.5 * math.sin(angle * 2))),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintSparkles(Canvas canvas, Size size, double t) {
    for (final s in sparkles) {
      final lp = _seg(t, s.startT, s.startT + 0.35);
      if (lp <= 0 || lp >= 1) continue;
      // Twinkle: grow then shrink.
      final scale = math.sin(lp * math.pi);
      final pos =
          Offset(s.position.dx * size.width, s.position.dy * size.height);
      _drawStar(
        canvas,
        pos,
        s.maxRadius * scale,
        s.color.withValues(alpha: scale),
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = radius * 0.5
      ..strokeCap = StrokeCap.round;
    // A simple 4-point sparkle.
    canvas.drawLine(
      center + Offset(-radius, 0),
      center + Offset(radius, 0),
      paint,
    );
    canvas.drawLine(
      center + Offset(0, -radius),
      center + Offset(0, radius),
      paint,
    );
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
