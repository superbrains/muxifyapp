import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class LyricsButtonWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const LyricsButtonWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.padding,
            vertical: 8.padding,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24.icon),
              8.row,
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 14.font,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

