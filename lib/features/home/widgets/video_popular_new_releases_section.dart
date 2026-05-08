import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/video_cover_image.dart';

class VideoPopularNewReleasesSection extends StatelessWidget {
  final List<VideoItem> items;
  final void Function(VideoItem item)? onItemTap;

  const VideoPopularNewReleasesSection({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 24.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular New Releases',
                style: AppTextStyles.heading2.copyWith(fontSize: 18.font),
              ),
            ],
          ),
        ),
        16.column,
        SizedBox(
          height: 164.maxHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => 11.row,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _VideoLargeCard(
                item: item,
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VideoLargeCard extends StatelessWidget {
  final VideoItem item;
  final VoidCallback? onTap;

  const _VideoLargeCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap == null) return;
        HapticFeedback.lightImpact();
        onTap!();
      },
      child: SizedBox(
        width: 156.maxWidth,
        height: 163.maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: VideoCoverImage(
                imageUrl: item.imageUrl,
                width: 156.maxWidth,
                height: 113.maxHeight,
              ),
            ),
            9.column,
            Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.font,
                color: AppColors.text.withValues(alpha: 0.75),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            6.column,
            Row(
              children: [
                _CreatorAvatar(url: item.creatorImageUrl, radius: 8.radius),
                8.row,
                Expanded(
                  child: Text(
                    item.creator,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11.font,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _CreatorAvatar extends StatelessWidget {
  final String url;
  final double radius;
  const _CreatorAvatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    final t = url.trim();
    if (t.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.text.withValues(alpha: 0.15),
        child: Icon(
          Icons.person,
          size: radius * 1.2,
          color: AppColors.text.withValues(alpha: 0.45),
        ),
      );
    }
    final isNetwork = t.startsWith('http://') || t.startsWith('https://');
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.text.withValues(alpha: 0.15),
      backgroundImage: isNetwork ? NetworkImage(t) : AssetImage(t) as ImageProvider,
    );
  }
}

