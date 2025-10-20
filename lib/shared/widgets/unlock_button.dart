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
  final Color? iconColor;
  final double? borderRadius;
  final double? iconSize;
  final double? spacing;
  final double? fontSize;
  final BoxBorder? border;
  
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
    this.iconColor,
    this.borderRadius,
    this.iconSize,
    this.spacing,
    this.fontSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 5.padding, vertical: 4.padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.text.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(borderRadius ?? 20.radius),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              Image.asset(
                iconPath!,
                width: iconSize ?? 14.maxWidth,
                height: iconSize ?? 14.maxHeight,
                color: iconColor,
              ),
              SizedBox(width: spacing ?? 4.padding),
            ],
            Text(
              text,
              style: AppTextStyles.unlockButtonText.copyWith(color: textColor, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
