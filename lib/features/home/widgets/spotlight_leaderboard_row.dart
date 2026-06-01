import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// A compact, chart-style leaderboard row (rank · avatar/cover · name · value).
/// Used for the gift-leaderboard tabs (Most Gifted Artist/Track/Creator/Video,
/// Top Giver) — the big banner [SpotlightDetailCard] is reserved for curated
/// Spotlight items only.
class SpotlightLeaderboardRow extends StatelessWidget {
  final SpotlightItem item;
  final VoidCallback? onTap;

  const SpotlightLeaderboardRow({super.key, required this.item, this.onTap});

  bool get _isPerson =>
      item.kind == SpotlightKind.artist || item.kind == SpotlightKind.giver;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7.padding, horizontal: 16.padding),
        child: Row(
          children: [
            SizedBox(width: 22.maxWidth, child: _rank()),
            12.row,
            _thumb(),
            14.row,
            Expanded(child: _titleBlock()),
            12.row,
            _metric(),
          ],
        ),
      ),
    );
  }

  Widget _rank() {
    final rank = item.rank;
    if (rank == null) return const SizedBox.shrink();
    final top3 = rank <= 3;
    return Text(
      '$rank',
      textAlign: TextAlign.center,
      style: AppTextStyles.heading2.copyWith(
        fontSize: 15.font,
        fontWeight: top3 ? FontWeight.w800 : FontWeight.w600,
        color: top3 ? _rankColor(rank) : AppColors.text.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _thumb() {
    final size = 54.maxWidth;
    final radius = _isPerson ? size : 10.radius;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: (item.rank != null && item.rank! <= 3)
            ? Border.all(color: _rankColor(item.rank!), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: _cover(size),
      ),
    );
  }

  Widget _cover(double size) {
    final url = item.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _fallback();
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholder: _fallback(),
      errorWidget: _fallback(),
    );
  }

  Widget _fallback() {
    if (_isPerson) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.glassyAccent, AppColors.glassyDark],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          _initials(item.title),
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18.font,
            fontWeight: FontWeight.w700,
            color: AppColors.text.withValues(alpha: 0.85),
          ),
        ),
      );
    }
    return Image.asset(
      'assets/pngs/spotlight_placeholder.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15.font,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.medal != null || item.artist.isNotEmpty) ...[
          5.column,
          Row(
            children: [
              if (item.medal != null) ...[
                _medalChip(item.medal!),
                if (item.artist.isNotEmpty) 6.row,
              ],
              if (item.artist.isNotEmpty)
                Flexible(
                  child: Text(
                    item.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _metric() {
    if (item.metricPrimary.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/pngs/Bitcoin_musixfy.png',
              width: 15.maxWidth,
              height: 15.maxWidth,
            ),
            5.row,
            Text(
              item.metricPrimary,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        if (item.metricSecondary.isNotEmpty) ...[
          3.column,
          Text(
            item.metricSecondary,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.font,
              color: AppColors.text.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _medalChip(String medal) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.padding, vertical: 2.padding),
      decoration: BoxDecoration(
        color: AppColors.glassyLight,
        borderRadius: BorderRadius.circular(20.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 11.font, color: _medalColor(medal)),
          3.row,
          Text(
            _titleCase(medal),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  static Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.text;
    }
  }

  static Color _medalColor(String medal) {
    switch (medal.toLowerCase()) {
      case 'diamond':
        return const Color(0xFF7FD7FF);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'crown':
        return const Color(0xFFFFB347);
      case 'iron':
        return const Color(0xFFB0B0B0);
      default:
        return AppColors.badgeRating;
    }
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
