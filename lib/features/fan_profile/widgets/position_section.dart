import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class PositionSection extends StatelessWidget {
  const PositionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        15.column,
        Row(
          children: [
            // Gifts Record Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(22.padding),
                decoration: BoxDecoration(
                  // color: AppColors.text.withValues(alpha: 0.1),
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
                child: Row(
                  children: [
                    Image.asset(
                      'assets/pngs/Bitcoin_musixfy.png',
                      width: 40.icon,
                      height: 40.icon,
                    ),
                    15.row,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textAlign: TextAlign.start,

                          text: TextSpan(
                            style: AppTextStyles.displayText.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w400,
                            ),
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
                                text: '100,250',
                                style: AppTextStyles.displayText.copyWith(
                                  color: AppColors.text,
                                  fontSize: 18.font,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 4.column,
                        Text(
                          'Gifts Record',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text.withValues(alpha: 0.7),
                            fontSize: 15.font,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            10.row,
            // Leaderboard Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(22.padding),
                decoration: BoxDecoration(
                  // color: AppColors.glassyDark,
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
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 40.maxWidth,
                      height: 40.maxHeight,
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/pngs/stats.png',
                        width: 18.icon,
                        height: 16.icon,
                      ),
                    ),
                    15.row,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#2',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.text,
                            fontSize: 21.font,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // 4.column,
                        Text(
                          'Leaderboard',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text.withValues(alpha: 0.7),
                            fontSize: 15.font,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
