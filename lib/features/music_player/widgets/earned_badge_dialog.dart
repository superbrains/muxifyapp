import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class EarnedBadgeDialog extends StatelessWidget {
  const EarnedBadgeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20.padding,
        vertical: 24.padding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.radius),
        side: BorderSide(
          color: AppColors.text.withValues(alpha: 0.3),
          width: 1.border,
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.padding,
            20.padding,
            16.padding,
            24.padding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Congratulation!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.text,
                  fontSize: 24.font,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              8.column,
              Text(
                'You just earned a new badge + coins',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  fontSize: 18.font,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              20.column,
              // Badge artwork
              Image.asset(
                'assets/pngs/earned_badge.png',
                fit: BoxFit.contain,
                width: 220.maxWidth,
              ),
              8.column,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pngs/Bitcoin_musixfy.png',
                    width: 43.icon,
                    height: 43.icon,
                  ),

                  10.row,

                  Text(
                    'm100,250',
                    style: AppTextStyles.displayText.copyWith(
                      color: AppColors.text,
                      fontSize: 15.font,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              124.column,
              // App logo text
              Image.asset(
                'assets/pngs/logo_text.png',
                height: 34.maxHeight,
                width: 132.maxWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
