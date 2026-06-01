import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';
import 'package:muxify/features/fan_profile/widgets/achievement_icon.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.badges});

  final List<UserBadge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.text,
              fontSize: 16.font,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.column,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.padding,
              vertical: 24.padding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.radius),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.military_tech,
                  color: AppColors.text.withValues(alpha: 0.4),
                  size: 32.icon,
                ),
                8.column,
                Text(
                  'No badges yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontSize: 14.font,
                  ),
                ),
                4.column,
                Text(
                  'Send gifts, follow artists and unlock content to earn badges.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                    fontSize: 12.font,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        10.column,
        GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];

            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.padding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.radius),
                border: Border.all(
                  color: AppColors.text.withValues(alpha: 0.1),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.text.withValues(alpha: 0.1),
                    AppColors.background.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AchievementIcon(
                    icon: badge.icon,
                    color: badge.color,
                    size: 62.maxWidth,
                    glyph: Icons.military_tech,
                  ),
                  8.column,
                  Text(
                    badge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text,
                      fontSize: 14.font,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
