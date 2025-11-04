import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class CenteredHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTap;
  final IconData? backIcon;
  final double? iconSize;
  final Color? iconColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CenteredHeaderWidget({
    super.key,
    required this.title,
    this.onBackTap,
    this.backIcon,
    this.iconSize,
    this.iconColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Centered title
        Center(
          child: Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: fontSize ?? 20.font,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        ),
        // Back arrow on the left
        if (onBackTap != null)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onBackTap?.call();
              },
              child: Icon(
                backIcon ?? Icons.arrow_back,
                color: iconColor ?? AppColors.text,
                size: iconSize ?? 30.icon,
              ),
            ),
          ),
      ],
    );
  }
}
