import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/widgets/gift_me_modal.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          // padding: EdgeInsets.symmetric(horizontal: 20.padding),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns
            mainAxisSpacing: 15, // Space between rows
            crossAxisSpacing: 15, // Space between columns
            childAspectRatio: 0.8, // Width/Height ratio
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            // Different badge images and multipliers
            final badgeImages = [
              'assets/pngs/badge_1.png',
              'assets/pngs/badge_2.png',
              'assets/pngs/badge_3.png',
              'assets/pngs/badge_4.png',
              'assets/pngs/badge_1.png',
              'assets/pngs/badge_2.png',
            ];

            return GestureDetector(
              onTap: () {
                GiftMeModal.show(context);
              },
              child: Container(
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
                      child: Image.asset(badgeImages[index]),
                    ),
                    8.column,
                    Text(
                      'Iron Fan',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.text,
                        fontSize: 14.font,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
