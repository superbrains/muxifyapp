import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

/// Hero "Play All" CTA. Large red pill with a circular play glyph at the
/// leading edge — visually consistent with the now-playing screen circle
/// controls. Disabled state dims the surface and removes the shadow.
class PlayAllButton extends StatelessWidget {
  const PlayAllButton({
    super.key,
    required this.onPressed,
    required this.subtitle,
    this.label = 'Play All',
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || onPressed == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: disabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
        child: Container(
          height: 64.maxHeight,
          padding: EdgeInsets.symmetric(horizontal: 8.padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.buttonColor,
                Color(0xFFB52E22),
              ],
            ),
            borderRadius: BorderRadius.circular(36.radius),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.buttonColor.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                height: 48.maxHeight,
                width: 48.maxWidth,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.text,
                  size: 30.icon,
                ),
              ),
              16.row,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 17.font,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    2.column,
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12.font,
                        color: AppColors.text.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.shuffle_rounded,
                color: AppColors.text.withValues(alpha: 0.85),
                size: 22.icon,
              ),
              16.row,
            ],
          ),
        ),
      ),
    );
  }
}
