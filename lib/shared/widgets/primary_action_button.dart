import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final String? iconPath;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? iconSize;
  final double? spacing;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BoxBorder? border;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onTap,
    this.iconPath,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.iconSize,
    this.spacing,
    this.fontSize,
    this.fontWeight,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap?.call();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: width ?? double.infinity,
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: iconPath != null ? 16.padding : 0,
          vertical: 14.padding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.buttonColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 26.radius),
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
              SizedBox(width: spacing ?? 6.padding),
            ],
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 16.font,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
