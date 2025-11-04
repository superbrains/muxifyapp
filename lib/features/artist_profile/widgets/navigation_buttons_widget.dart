import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final String? mediaType;

  const NavigationButtonsWidget({super.key, this.mediaType});

  @override
  Widget build(BuildContext context) {
    // Show video buttons when mediaType is "Videos"
    if (mediaType == 'Videos') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 15.padding,
        children: [
          Expanded(
            child: _buildNavButton(
              'New Release',
              'assets/pngs/new_release.png',
              () {
                context.push('${AppRouter.newRelease}?mediaType=Videos');
              },
            ),
          ),
          Expanded(
            child: _buildNavButton('All Videos', 'assets/pngs/singles.png', () {
              context.push(AppRouter.allVideos);
            }),
          ),
        ],
      );
    }

    // Default music buttons
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton('New Release', 'assets/pngs/new_release.png', () {
          context.push(AppRouter.newRelease);
        }),
        _buildNavButton('Singles', 'assets/pngs/singles.png', () {
          context.push(AppRouter.singles);
        }),
        _buildNavButton('Albums', 'assets/pngs/albums.png', () {
          context.push(AppRouter.albums);
        }),
      ],
    );
  }

  Widget _buildNavButton(String label, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 117.maxWidth,
        height: 85.maxHeight,
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.3),
            width: 1.09.border,
          ),
          borderRadius: BorderRadius.circular(15.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, width: 24.icon, height: 24.icon),
            8.column,
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14.font,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
