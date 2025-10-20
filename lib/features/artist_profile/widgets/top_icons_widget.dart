import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/shared/widgets/circular_icon_button.dart';

/// Reusable CircularIconButton widget for any icon in a circular container.

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
            // Use the reusable CircularIconButton for back
            CircularIconButton(
              onTap: onBackTap,
              icon: Icons.arrow_back_ios,
            ),
            // Search and Menu icons
            Row(
              children: [
                CircularIconButton(
                  onTap: onSearchTap,
                  icon: Icons.search_rounded,
                ),
                15.row,
                CircularIconButton(
                  onTap: onMenuTap,
                  icon: Icons.more_vert,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
