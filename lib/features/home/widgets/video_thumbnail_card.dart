import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/video_cover_image.dart';

class VideoThumbnailCard extends StatelessWidget {
  final VideoItem item;
  final VoidCallback? onTap;

  const VideoThumbnailCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.radius),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoCoverImage(
                  imageUrl: item.imageUrl,
                  width: 110.maxWidth,
                  height: 80.buttonHeight,
                ),
                Container(
                  width: 110.maxWidth,
                  height: 3.maxHeight,
                  color: AppColors.buttonColor,
                ),
              ],
            ),
          ),
          8.column,
          SizedBox(
            width: 110.maxWidth,
            child: Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.font,
                color: AppColors.text.withValues(alpha: 0.75),
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

