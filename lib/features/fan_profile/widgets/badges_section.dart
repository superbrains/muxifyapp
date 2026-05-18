import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.badges});

  final List<UserBadge> badges;

  static const List<String> _fallbackBadgeAssets = [
    'assets/pngs/badge_1.png',
    'assets/pngs/badge_2.png',
    'assets/pngs/badge_3.png',
    'assets/pngs/badge_4.png',
  ];

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
            padding: EdgeInsets.all(16.padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.radius),
              border: Border.all(color: AppColors.text.withValues(alpha: 0.1)),
            ),
            child: Text(
              'No badges earned yet.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
                fontSize: 12.font,
              ),
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
            final fallbackAsset =
                _fallbackBadgeAssets[index % _fallbackBadgeAssets.length];
            final hasIcon = badge.icon.trim().isNotEmpty;

            return Container(
              alignment: Alignment.center,
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
                  SizedBox(
                    width: 67.maxWidth,
                    height: 70.maxHeight,
                    child: hasIcon
                        ? Image.network(
                            badge.icon,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(fallbackAsset),
                          )
                        : Image.asset(fallbackAsset),
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
