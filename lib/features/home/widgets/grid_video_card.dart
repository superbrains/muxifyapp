import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';

class GridVideoCard extends StatelessWidget {
  final VideoItem item;
  final VoidCallback? onTap;

  const GridVideoCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.radius),
            child: Image.asset(
              item.imageUrl,
              width: double.infinity,
              height: 113.maxHeight,
              fit: BoxFit.cover,
            ),
          ),
          5.column,
          Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12.font,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          2.column,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 8.radius,
                      backgroundImage: AssetImage(item.creatorImageUrl),
                    ),
                    8.row,
                    Text(
                      item.creator,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 10.font,
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Spacer(),
              Flexible(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.views ?? '0',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 10.font,
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    4.row,
                    Icon(
                      Icons.visibility_outlined,
                      size: 12.icon,
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
