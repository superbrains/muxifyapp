import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class FanProfileSection extends StatelessWidget {
  final String username;
  final String profileImagePath;
  final String verifyBadgePath;
  final VoidCallback? onGiftTap;

  const FanProfileSection({
    super.key,
    required this.username,
    required this.profileImagePath,
    required this.verifyBadgePath,
    this.onGiftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: Image.asset(
                    profileImagePath,
                    width: 100.maxWidth,
                    height: 100.maxHeight,
                  ),
                ),
                10.column,
                Text(
                  username,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontSize: 22.font,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Verify badge at the top-right corner
            Positioned(
              top: 2.padding,
              right: 2.padding,
              child: Image.asset(
                verifyBadgePath,
                width: 24.icon,
                height: 24.icon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
