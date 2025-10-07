import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';

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
            // Album Cover
            Expanded(
              child: SizedBox(
                width: 241.maxWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.radius),
                  child: Image.asset(
                    item.imageUrl ?? 'assets/pngs/spotlight_placeholder.png',
                    fit: BoxFit.cover,
                    height:
                        double.infinity, // Takes full height of parent SizedBox
                  ),
                ),
              ),
            ),

            20.row,
            // Track Details
            Column(
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
                // Artist
                Text(
                  item.artist,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                12.column,
                // Play Count
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
                16.column,
                // Unlock Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onUnlockTap?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.padding,
                      vertical: 8.padding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.text.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20.radius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/pngs/Bitcoin_musixfy.png',
                          width: 22.maxWidth,
                          height: 22.maxHeight,
                        ),
                        8.row,
                        Text(
                          'Unlock',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.font,
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
