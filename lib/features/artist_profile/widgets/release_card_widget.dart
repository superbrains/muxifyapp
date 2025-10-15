import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/widgets/play_button_widget.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class ReleaseCardWidget extends StatelessWidget {
  final NewReleaseItem release;
  final VoidCallback? onTap;
  final VoidCallback? onUnlockTap;

  const ReleaseCardWidget({
    super.key,
    required this.release,
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art with Unlock Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.radius),
                      image: DecorationImage(
                        image: AssetImage(release.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Button Overlay - Different buttons based on unlock status
                  Positioned(
                    bottom: 8.padding,
                    right: 8.padding,
                    child: release.isUnlocked
                        ? PlayButtonWidget(
                            height: 40.maxHeight,
                            width: 40.maxWidth,
                            iconHeight: 13.icon,
                            iconWidth: 15.icon,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Handle play action
                            },
                          )
                        : UnlockButton(
                            text: 'Unlock',
                            iconPath: 'assets/pngs/Bitcoin_musixfy.png',
                            backgroundColor: AppColors.text.withValues(
                              alpha: 0.75,
                            ),
                            iconSize: 22.icon,
                            spacing: 4.padding,
                            borderRadius: 22.radius,
                            onTap: onUnlockTap,
                          ),
                  ),
                ],
              ),
            ),
            12.column,
            // Title
            Text(
              release.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.column,
            // Artist
            Text(
              release.artist,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.font,
                fontWeight: FontWeight.w400,
                color: AppColors.text.withValues(alpha: 0.64),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
