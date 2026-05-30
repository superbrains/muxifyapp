import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/video_cover_image.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

class _CreatorAvatar extends StatelessWidget {
  final String url;
  final double radius;
  const _CreatorAvatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    final t = url.trim();
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.text.withValues(alpha: 0.15),
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: AppColors.text.withValues(alpha: 0.45),
      ),
    );
    if (t.isEmpty) return fallback;
    final d = radius * 2;
    if (t.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(t, width: d, height: d, fit: BoxFit.cover),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: d,
        height: d,
        child: AuthNetworkImage(
          path: t,
          width: d,
          height: d,
          fit: BoxFit.cover,
          placeholder: fallback,
          errorWidget: fallback,
        ),
      ),
    );
  }
}

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
            child: VideoCoverImage(
              imageUrl: item.imageUrl,
              width: double.infinity,
              height: 113.maxHeight,
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
                    _CreatorAvatar(url: item.creatorImageUrl, radius: 8.radius),
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
