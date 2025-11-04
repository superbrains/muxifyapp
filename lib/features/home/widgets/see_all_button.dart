import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class SeeAllButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int? maxLines;

  const SeeAllButton({
    super.key,
    this.onTap,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin:
            margin ??
            EdgeInsets.only(
              right: 16.padding,
              // bottom: 16.padding,
            ),
        alignment: Alignment.center,
        width: width ?? 64.maxWidth,
        height: height ?? 30.buttonHeight,
        // padding: EdgeInsets.symmetric(vertical: 12.padding),
        decoration:
            decoration ??
            BoxDecoration(
              color: AppColors.text.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(25.radius),
            ),
        child: Text(
          text ?? 'See All',
          textAlign: textAlign ?? TextAlign.center,
          style:
              textStyle ??
              AppTextStyles.bodyMedium.copyWith(
                fontWeight: fontWeight ?? FontWeight.w600,
                fontSize: fontSize ?? 12.font,
                color: color ?? AppColors.background,
              ),
        ),
      ),
    );
  }
}
