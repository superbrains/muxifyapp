import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class UnlockButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final String? iconPath;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const UnlockButton({
    super.key,
    this.text = 'Unlock',
    this.onTap,
    this.iconPath,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: width,
        height: height,
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 16.padding, vertical: 8.padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.text.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(borderRadius ?? 20.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              Image.asset(iconPath!, width: 22.maxWidth, height: 22.maxHeight),
              8.row,
            ],
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.font,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
