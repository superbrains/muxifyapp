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

          // NOTE: The "Following" pill was removed — fan-to-fan following is not
          // a backend concept yet. "Gift Me" (in the profile body) is the
          // primary action on another fan's profile.
          const Spacer(),
        ],
      ),
    );
  }
}
