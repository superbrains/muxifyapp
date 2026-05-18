import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';
import 'package:muxify/features/fan_profile/widgets/medal_info_modal.dart';

class MedalsSection extends StatelessWidget {
  const MedalsSection({super.key, required this.medals});

  final List<UserMedal> medals;

  static const String _fallbackAsset = 'assets/pngs/earned_badge.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medals',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.text,
            fontSize: 16.font,
            fontWeight: FontWeight.w400,
          ),
        ),
        10.column,
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
          child: medals.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.padding),
                  child: Text(
                    'No medals earned yet.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 12.font,
                    ),
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) => 15.row,
                  padding: EdgeInsets.symmetric(horizontal: 17.padding),
                  scrollDirection: Axis.horizontal,
                  itemCount: medals.length,
                  itemBuilder: (context, index) {
                    final medal = medals[index];
                    final hasIcon = medal.icon.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: () {
                        MedalInfoModal.show(
                          context,
                          medalName: medal.name,
                          medalDescription: medal.description,
                          medalImagePath:
                              hasIcon ? medal.icon : _fallbackAsset,
                        );
                      },
                      child: SizedBox(
                        width: 57.maxWidth,
                        height: 61.maxHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.radius),
                          child: hasIcon
                              ? Image.network(
                                  medal.icon,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset(_fallbackAsset),
                                )
                              : Image.asset(_fallbackAsset),
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
