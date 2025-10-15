import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class StickerText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color strokeColor;
  final double strokeWidth;
  final double rotation;

  const StickerText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.textColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.rotation = -0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Stack(
        children: [
          // Stroke (outline) text
          Text(
            text,
            style: AppTextStyles.displayText.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: strokeColor,
              shadows: [
                Shadow(
                  offset: Offset(-strokeWidth, -strokeWidth),
                  color: strokeColor,
                ),
                Shadow(
                  offset: Offset(strokeWidth, -strokeWidth),
                  color: strokeColor,
                ),
                Shadow(
                  offset: Offset(strokeWidth, strokeWidth),
                  color: strokeColor,
                ),
                Shadow(
                  offset: Offset(-strokeWidth, strokeWidth),
                  color: strokeColor,
                ),
                Shadow(offset: Offset(-strokeWidth, 0), color: strokeColor),
                Shadow(offset: Offset(strokeWidth, 0), color: strokeColor),
                Shadow(offset: Offset(0, -strokeWidth), color: strokeColor),
                Shadow(offset: Offset(0, strokeWidth), color: strokeColor),
              ],
            ),
          ),
          // Main text
          Text(
            text,
            style: AppTextStyles.displayText.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
