import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class FanProfileHeader extends StatelessWidget {
  const FanProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 26.padding,
        right: 21.padding,
        top: 20.buttonHeight,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back, color: AppColors.text, size: 30.icon),
          ),

          // const Spacer(),
          10.row,
          // Title
          Text(
            'Fan Profile',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: 18.font,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          // Following Button
          Container(
            constraints: BoxConstraints(
              maxWidth: 123.maxWidth,
              maxHeight: 48.buttonHeight,
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.radius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.padding,
                  vertical: 12.padding,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: AppColors.text, size: 24.icon),
                  4.row,
                  Text(
                    'Following',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
