import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/shared/widgets/primary_action_button.dart';

class UnlockSuccessDialog extends StatelessWidget {
  final String heading;
  final String message;
  final String mediaTitle;
  final String mediaSubtitle;
  final String imagePath;
  final String primaryButtonText;
  final VoidCallback onPrimary;

  const UnlockSuccessDialog({
    super.key,
    required this.heading,
    required this.message,
    required this.mediaTitle,
    required this.mediaSubtitle,
    required this.imagePath,
    required this.primaryButtonText,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.padding),
      child: Container(
        width: 380.maxWidth,
        padding: EdgeInsets.only(
          left: 39.padding,
          right: 39.padding,
          top: 44.padding,
          bottom: 22.padding,
        ),
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.circular(22.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              heading,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.text,
                fontSize: 28.font,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            6.column,
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text,
                fontSize: 18.font,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            47.column,
            ClipRRect(
              borderRadius: BorderRadius.circular(10.radius),
              child: Image.asset(
                imagePath,
                width: 112.maxWidth,
                height: 112.maxHeight,
                fit: BoxFit.cover,
              ),
            ),
            12.column,
            Text(
              mediaTitle,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.text,
                fontSize: 20.font,
                fontWeight: FontWeight.w500,
              ),
            ),
            7.column,
            Text(
              mediaSubtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
                fontSize: 20.font,
                fontWeight: FontWeight.w500,
              ),
            ),
            48.column,
            PrimaryActionButton(
              text: primaryButtonText,
              onTap: onPrimary,
              height: 56.buttonHeight,
              width: double.infinity,
              backgroundColor: AppColors.buttonColor,
              borderRadius: 26.radius,
            ),
            26.column,
            Image.asset(
              'assets/pngs/logo_text.png',
              height: 22.maxHeight,
              width: 85.maxWidth,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
