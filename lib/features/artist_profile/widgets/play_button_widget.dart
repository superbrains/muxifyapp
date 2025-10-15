import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';

class PlayButtonWidget extends StatelessWidget {
  final double height;
  final double width;
  final double iconHeight;
  final double iconWidth;
  final VoidCallback onTap;
  final Color? color;
  final String? iconPath;

  const PlayButtonWidget({
    super.key,
    required this.height,
    required this.width,
    required this.iconHeight,
    required this.iconWidth,
    required this.onTap,
    this.color,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? AppColors.buttonColor,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          iconPath ?? 'assets/pngs/play.png',
          height: iconHeight,
          width: iconWidth,
        ),
      ),
    );
  }
}
