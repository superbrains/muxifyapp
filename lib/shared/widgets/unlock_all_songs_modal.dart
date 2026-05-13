import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

class UnlockAllSongsModal extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onUnlockPremium;
  final VoidCallback? onUnlockFree;

  const UnlockAllSongsModal({
    super.key,
    this.onClose,
    this.onUnlockPremium,
    this.onUnlockFree,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 371.maxWidth,
        height: 370.maxHeight,
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.1),
            width: 1.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClose?.call();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 7.padding, right: 8.padding),
                  width: 29.maxWidth,
                  height: 29.maxHeight,

                  decoration: BoxDecoration(
                    color: AppColors.modalCancelButtonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.text,
                    size: 11.icon,
                  ),
                ),
              ),
            ),
            // 40.column,
            // Content Options
            Padding(
              padding: EdgeInsets.only(left: 36.padding, right: 37.padding),
              child: Column(
                children: [
                  Text(
                    'Unlock all songs',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 21.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  40.column,
                  // Premium Option
                  _buildUnlockOption(
                    imageUrl: 'assets/pngs/Bitcoin_musixfy.png',
                    title: 'm100,250',
                    subtitle: 'Unlock Now',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onUnlockPremium?.call();
                    },
                  ),
                  22.column,
                  // Free Option
                  _buildUnlockOption(
                    imageUrl: 'assets/pngs/Bitcoin_musixfy.png',
                    title: 'Free Play',
                    subtitle: 'Sponsored',
                    hasInfoIcon: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onUnlockFree?.call();
                    },
                  ),
                ],
              ),
            ),

            Spacer(),
            // Disclaimer Section
            Padding(
              padding: EdgeInsets.only(
                left: 36.padding,
                right: 37.padding,
                bottom: 25.padding,
              ),
              child: Column(
                children: [
                  Text(
                    'Disclaimer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.column,
                  Text(
                    'Unlocking all songs spends coins from your wallet. Once confirmed, coin spends are final and cannot be reversed. Check your balance before you proceed.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockOption({
    required String imageUrl,
    required String title,
    required String subtitle,
    bool hasInfoIcon = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            // Image
            Container(
              width: 36.maxWidth,
              height: 36.maxHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.radius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.radius),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            12.row,
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16.font,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),

                  4.column,
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.font,
                          fontWeight: FontWeight.w400,
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                      if (hasInfoIcon) ...[
                        8.row,
                        Icon(
                          Icons.info_outline,
                          color: AppColors.cautionIcon,
                          size: 16.icon,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Unlock Button
            UnlockButton(
              text: 'Unlock',
              iconPath: 'assets/pngs/Bitcoin_musixfy.png',
              backgroundColor: AppColors.toggleSelected,
              iconSize: 16.icon,
              spacing: 6.padding,
              padding: EdgeInsets.symmetric(
                horizontal: 12.padding,
                vertical: 8.padding,
              ),
              borderRadius: 20.radius,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
