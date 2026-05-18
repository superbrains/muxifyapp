import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class FanProfileSection extends StatelessWidget {
  final String username;
  final String fallbackProfileImagePath;
  final String verifyBadgePath;
  final String? avatarUrl;
  final bool showVerifyBadge;
  final VoidCallback? onGiftTap;

  const FanProfileSection({
    super.key,
    required this.username,
    required this.fallbackProfileImagePath,
    required this.verifyBadgePath,
    this.avatarUrl,
    this.showVerifyBadge = true,
    this.onGiftTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: hasNetworkAvatar
                      ? Image.network(
                          avatarUrl!,
                          width: 100.maxWidth,
                          height: 100.maxHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            fallbackProfileImagePath,
                            width: 100.maxWidth,
                            height: 100.maxHeight,
                          ),
                        )
                      : Image.asset(
                          fallbackProfileImagePath,
                          width: 100.maxWidth,
                          height: 100.maxHeight,
                        ),
                ),
                10.column,
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    fontSize: 22.font,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (showVerifyBadge)
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
