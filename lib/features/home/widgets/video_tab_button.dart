import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class VideoTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const VideoTabButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 14.padding,
          vertical: 10.padding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text : AppColors.toggleUnselected,
          borderRadius: BorderRadius.circular(5.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.icon,
              color: isSelected ? AppColors.glassyDark : AppColors.text,
            ),
            8.row,
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.glassyDark : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

