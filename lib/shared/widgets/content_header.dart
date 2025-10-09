import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class ContentHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String filterText;
  final VoidCallback? onFilterTap;

  const ContentHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.filterText = 'Today, Latest',
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                title,
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 20.font,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontFamily: "Inter",
                ),
              ),
              4.column,
              // Subtitle/Date Info
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.font,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        // Filter Button
        GestureDetector(
          onTap: onFilterTap,
          child: Row(
            children: [
              Text(
                filterText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16.font,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text.withValues(alpha: 0.75),
                ),
              ),
              4.row,
              Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.text,
                size: 30.icon,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
