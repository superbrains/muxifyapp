import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class FollowingSection extends StatelessWidget {
  const FollowingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Following',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        5.column,
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.radius),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.text.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.2),
              ],
            ),
          ),
          height: 95.maxHeight,
          child: ListView.separated(
            separatorBuilder: (context, index) => 10.row,
            padding: EdgeInsets.symmetric(horizontal: 12.padding),
            scrollDirection: Axis.horizontal,
            itemCount: 7, // 6 avatars + 1 arrow
            itemBuilder: (context, index) {
              if (index == 6) {
                // Arrow at the end
                return Container(
                  width: 24.maxWidth,
                  height: 24.maxHeight,
                  decoration: BoxDecoration(
                    color: AppColors.text.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  margin: EdgeInsets.only(right: 12.padding),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.text,
                      size: 10.icon,
                    ),
                  ),
                );
              }

              return Container(
                alignment: Alignment.center,
                width: 45.maxWidth,
                // margin: EdgeInsets.only(right: 12.padding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: Image.asset(
                    'assets/pngs/fan_profile_image.png',
                    width: 45.maxWidth,
                    height: 45.maxHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
