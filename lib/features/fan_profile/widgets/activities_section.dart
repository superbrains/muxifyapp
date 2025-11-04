import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': 'assets/pngs/davido.png',
        'title': 'Played: Wizkid - Kese',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/davido.png',
        'title': 'Unlocked: Omah Lay - Moving',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/earned_badge.png',
        'title': 'New Medal: Mr Funny - Sabinus again',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/fan_profile_image.png',
        'title': 'Gifted: Mr Funny - Sabinus again',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/badge_1.png',
        'title': 'New Badge: Mr Funny - Sabinus again',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/badge_2.png',
        'title': 'New Badge: Mr Funny - Sabinus again',
        'time': 'Today • 5:10PM',
      },
      {
        'icon': 'assets/pngs/badge_3.png',
        'title': 'Unlocked: Omah Lay - Moving',
        'time': 'Today • 5:10PM',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        15.column,
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.padding),
            itemCount: activities.length,
            separatorBuilder: (context, index) => 16.column,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Row(
      children: [
        // Activity Icon
        ClipRRect(
          borderRadius: BorderRadius.circular(5.radius),
          child: Image.asset(
            activity['icon'],
            width: 45.maxWidth,
            height: 45.maxHeight,
            fit: BoxFit.cover,
          ),
        ),

        15.row,
        // Activity Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  fontSize: 14.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
              2.column,
              Text(
                activity['time'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                  fontSize: 12.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
