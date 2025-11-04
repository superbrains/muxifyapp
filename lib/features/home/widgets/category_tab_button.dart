import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class CategoryTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final double? width;
  final double? height;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTabButton({
    super.key,
    required this.title,
    required this.icon,
    this.width,
    this.height,
    this.paddingHorizontal,
    this.paddingVertical,
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
        height: height,
        width: width,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal ?? 16.padding,
          vertical: paddingVertical ?? 8.padding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glassyDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(icon, size: 24.icon, color: AppColors.text),
              8.row,
            ],
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
