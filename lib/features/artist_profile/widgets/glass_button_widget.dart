import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class GlassButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final bool showGiftIcon;

  const GlassButtonWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.showGiftIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: width ?? 144.maxWidth,
        height: height ?? 52.maxHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(35.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showGiftIcon) ...[
              Image.asset(
                'assets/pngs/gift.png',
                width: 28.icon,
                height: 28.icon,
              ),
              4.row,
            ],
            Text(
              text,
              style: AppTextStyles.specialText.copyWith(
                fontSize: 17.5.font,
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
