import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';

class TopIconsWidget extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onSearchTap;
  final VoidCallback onMenuTap;

  const TopIconsWidget({
    super.key,
    required this.onBackTap,
    required this.onSearchTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 22.padding,
          vertical: 10.padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onBackTap();
              },
              child: Container(
                padding: EdgeInsets.all(11.padding),
                width: 44.maxWidth,
                height: 44.maxHeight,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.text,
                    size: 22.icon,
                  ),
                ),
              ),
            ),
            // Comment and Menu icons
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSearchTap();
                  },
                  child: Container(
                    padding: EdgeInsets.all(11.padding),
                    width: 44.maxWidth,
                    height: 44.maxHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.text.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.text,
                      size: 22.icon,
                    ),
                  ),
                ),
                15.row,
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onMenuTap();
                  },
                  child: Container(
                    padding: EdgeInsets.all(11.padding),
                    width: 44.maxWidth,
                    height: 44.maxHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.text.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.text,
                      size: 22.icon,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
