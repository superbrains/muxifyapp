import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class TabOptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TabOptionButton({
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
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 20.padding,
          vertical: 10.padding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.toggleSelected
              : AppColors.toggleUnselected,
          borderRadius: BorderRadius.circular(25.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.icon,
              color: isSelected ? AppColors.toggleSelectedText : AppColors.text,
            ),
            8.row,
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.toggleSelectedText
                    : AppColors.text,
                fontWeight: FontWeight.w500,
                fontSize: 14.font,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
