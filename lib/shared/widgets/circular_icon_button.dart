import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';

class CircularIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final Color? backgroundColor;
  final double? buttonSize;
  final double? padding;

  const CircularIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.buttonSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all((padding ?? 11.padding)),
        width: buttonSize?.maxWidth ?? 44.maxWidth,
        height: buttonSize?.maxHeight ?? 44.maxHeight,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.text.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor ?? AppColors.text,
            size: iconSize ?? 22.icon,
          ),
        ),
      ),
    );
  }
}
