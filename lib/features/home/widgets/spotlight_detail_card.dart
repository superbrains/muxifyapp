import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class SpotlightDetailCard extends StatelessWidget {
  final SpotlightItem item;
  final VoidCallback? onTap;
  final VoidCallback? onUnlockTap;

  const SpotlightDetailCard({
    super.key,
    required this.item,
    this.onTap,
    this.onUnlockTap,
  });

  bool get _isPerson =>
      item.kind == SpotlightKind.artist || item.kind == SpotlightKind.giver;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.only(right: 16.padding),
        height: 200.buttonHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Cover / avatar with optional rank badge overlay.
            Expanded(
              child: SizedBox(
                width: 241.maxWidth,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.radius),
                      child: _buildCover(),
                    ),
                    if (item.rank != null)
                      Positioned(
                        top: 8.padding,
                        left: 8.padding,
                        child: _rankBadge(item.rank!),
                      ),
                  ],
                ),
              ),
            ),

            20.row,
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 18.font,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.column,
                  // Subtitle (artist name / medal / stats), with medal chip for givers.
                  Row(
                    children: [
                      if (item.medal != null) ...[
                        _medalChip(item.medal!),
                        8.row,
                      ],
                      Flexible(
                        child: Text(
                          item.artist,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.font,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.playCount.isNotEmpty) ...[
                    12.column,
                    // Gift / coin / play metric
                    Text(
                      item.playCount,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.font,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (!item.isUnlocked) ...[
                    16.column,
                    UnlockButton(
                      text: 'Unlock',
                      iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                      onTap: onUnlockTap,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final url = item.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _placeholderCover();
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      placeholder: _placeholderCover(),
      errorWidget: _placeholderCover(),
    );
  }

  Widget _placeholderCover() {
    // People without an avatar get an initials tile; content keeps the
    // branded artwork placeholder.
    if (_isPerson) return _initialsCover();
    return Image.asset(
      'assets/pngs/spotlight_placeholder.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    );
  }

  Widget _initialsCover() {
    final initials = _initialsOf(item.title);
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassyAccent, AppColors.glassyDark],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.heading2.copyWith(
          fontSize: 48.font,
          fontWeight: FontWeight.w700,
          color: AppColors.text.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  static String _initialsOf(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Widget _rankBadge(int rank) {
    final color = _rankColor(rank);
    final onColor = rank <= 3 ? Colors.black : AppColors.text;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.padding,
        vertical: 4.padding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.radius),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        '#$rank',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 12.font,
          fontWeight: FontWeight.w800,
          color: onColor,
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // gold
      case 2:
        return const Color(0xFFC0C0C0); // silver
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return AppColors.glassyAccent;
    }
  }

  Widget _medalChip(String medal) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.padding,
        vertical: 3.padding,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassyLight,
        borderRadius: BorderRadius.circular(20.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium,
              size: 12.font, color: _medalColor(medal)),
          4.row,
          Text(
            _titleCase(medal),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Color _medalColor(String medal) {
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
}
