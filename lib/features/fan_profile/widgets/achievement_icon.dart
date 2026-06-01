import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Renders a badge/medal icon. The backend stores either:
///   * a real image (media-proxy path like `/api/v1/media/...` or an absolute
///     URL) — loaded through [AuthNetworkImage] (JWT-aware), or
///   * a slug placeholder (e.g. `badge-first-gift`) until final art is uploaded
///     — rendered as a polished colored medallion using the badge's hex [color]
///     so the Achievement tab looks intentional rather than broken.
///
/// This keeps the UI production-ready today and automatically upgrades to the
/// real artwork the moment the seeded `Icon` values become proxy paths.
class AchievementIcon extends StatelessWidget {
  const AchievementIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 56,
    this.glyph = Icons.workspace_premium,
  });

  final String icon;
  final String color;
  final double size;
  final IconData glyph;

  bool get _isImage {
    final t = icon.trim().toLowerCase();
    return t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('/');
  }

  @override
  Widget build(BuildContext context) {
    final medallion = _Medallion(color: color, size: size, glyph: glyph);
    if (!_isImage) return medallion;

    return ClipOval(
      child: AuthNetworkImage(
        path: icon.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: medallion,
        errorWidget: medallion,
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.color, required this.size, required this.glyph});

  final String color;
  final double size;
  final IconData glyph;

  @override
  Widget build(BuildContext context) {
    final base = _parseHexColor(color) ?? AppColors.badgeRating;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(base, Colors.white, 0.25) ?? base,
            base,
            Color.lerp(base, Colors.black, 0.35) ?? base,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.45),
            blurRadius: size * 0.18,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(glyph, color: Colors.white, size: size * 0.5),
    );
  }
}

/// Parses `#RRGGBB` / `#AARRGGBB` (with or without leading `#`). Returns null
/// when the value isn't a hex color (e.g. a styling class), so callers fall
/// back to a default.
Color? _parseHexColor(String value) {
  var hex = value.trim().replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}
