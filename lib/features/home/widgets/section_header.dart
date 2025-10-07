import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget? leadingIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[leadingIcon!, 8.row],
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 18.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14.font,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
