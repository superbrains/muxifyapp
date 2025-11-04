import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/primary_action_button.dart';
import 'package:muxify/shared/widgets/centered_header_widget.dart';

class UnlockConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String primaryButtonText;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  // Premium unlock mode
  final bool isPremiumMode;
  final String? unlockTitle; // "Unlock Song" or "Unlock Video"
  final String? coinCost; // "-100,250"
  final bool showInsufficientCoinsError;
  final VoidCallback? onGetCoins;

  const UnlockConfirmBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primaryButtonText,
    required this.onClose,
    required this.onConfirm,
    this.isPremiumMode = false,
    this.unlockTitle,
    this.coinCost,
    this.showInsufficientCoinsError = false,
    this.onGetCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.padding,
        right: 20.padding,
        top: 16.padding,
        bottom: 24.padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CenteredHeaderWidget(
            title: unlockTitle ?? primaryButtonText,
            onBackTap: onClose,
          ),
          33.column,
          ClipRRect(
            borderRadius: BorderRadius.circular(10.radius),
            child: Image.asset(
              imagePath,
              width: 85.maxWidth,
              height: 85.maxHeight,
              fit: BoxFit.cover,
            ),
          ),
          15.column,
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.text,
              fontSize: 16.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          5.column,
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text,
              fontSize: 12.font,
              fontWeight: FontWeight.w400,
            ),
          ),
          18.column,
          // Show either Free Play or Coin Cost based on mode
          if (!isPremiumMode)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/pngs/Bitcoin_musixfy.png',
                  width: 35.icon,
                  height: 35.icon,
                ),
                8.row,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Play',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.text,
                        fontSize: 18.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Sponsored',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text,
                        fontSize: 13.font,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/pngs/Bitcoin_musixfy.png',
                  width: 35.icon,
                  height: 35.icon,
                ),
                10.row,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'm',
                        style: AppTextStyles.displayText.copyWith(
                          color: AppColors.text,
                          fontSize: 10.font,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: coinCost ?? '100,250',
                        style: AppTextStyles.displayText.copyWith(
                          color: AppColors.text,
                          fontSize: 18.font,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const Spacer(),
          // Show insufficient coins error if needed
          if (showInsufficientCoinsError) ...[
            Container(
              width: 282.maxWidth,
              height: 53.buttonHeight,
              padding: EdgeInsets.symmetric(
                horizontal: 25.padding,
                vertical: 16.padding,
              ),
              decoration: BoxDecoration(
                color: AppColors.buttonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.radius),
                border: Border.all(
                  color: AppColors.buttonColor.withValues(alpha: 0.5),
                  width: 1.border,
                ),
              ),
              child: Text(
                'You don\'t have enough coins to unlock',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  fontSize: 13.font,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            16.column,
          ],
          Text(
            'Terms of Purchase',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12.font,
              color: AppColors.text,
              fontWeight: FontWeight.w400,
            ),
          ),
          8.column,
          Text(
            isPremiumMode
                ? 'Lorem ipsum dolor sit amet consectetur. Purus odio ultrices eleifend vel sed. At praesent scelerisque nibh blandit nulla adipiscing sed rhoncus.'
                : 'By clicking Unlock Song, you have given consent to consume this media for free in the event of ads may play within. Lorem ipsum dolor sit amet consectetur. Purus odio ultrices eleifenduis vel sed.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 9.font,
              color: AppColors.text.withValues(alpha: 0.6),
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          27.column,
          // Show either Get Coins button or Unlock button
          if (isPremiumMode && onGetCoins != null)
            GestureDetector(
              onTap: onGetCoins,
              child: Container(
                width: double.infinity,
                height: 56.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100.radius),
                ),
                child: Stack(
                  children: [
                    // Centered text
                    Center(
                      child: Text(
                        'Get Coins',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.text,
                          fontSize: 18.font,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    // Image on the left
                    Positioned(
                      left: 14.padding,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/pngs/multi_coin.png',
                          width: 60.maxWidth,
                          height: 35.maxHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            PrimaryActionButton(
              text: primaryButtonText,
              onTap: onConfirm,
              height: 56.buttonHeight,
              width: double.infinity,
              backgroundColor: AppColors.buttonColor,
              borderRadius: 100.radius,
            ),
        ],
      ),
    );
  }
}
