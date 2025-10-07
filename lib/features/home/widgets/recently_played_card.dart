import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';

class RecentlyPlayedCard extends StatelessWidget {
  final RecentlyPlayedItem item;
  final VoidCallback? onTap;

  const RecentlyPlayedCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80.buttonHeight,
            height: 80.buttonHeight,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6E1E1E).withValues(alpha: 0.4),
                  const Color(0xFF6E1E1E).withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Container(
              width: 24.icon,
              height: 24.icon,
              margin: EdgeInsets.symmetric(
                horizontal: 12.padding,
                vertical: 12.padding,
              ),
              decoration: BoxDecoration(
                color: AppColors.text,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.background,
                size: 16.icon,
              ),
            ),
          ),
          8.column, 
          SizedBox(
            width: 80.maxWidth,
            child: Text(
              textAlign: TextAlign.center,
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.font,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
