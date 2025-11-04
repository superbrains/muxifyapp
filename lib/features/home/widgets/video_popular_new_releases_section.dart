import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';

class VideoPopularNewReleasesSection extends StatelessWidget {
  final List<VideoItem> items;

  const VideoPopularNewReleasesSection({super.key, required this.items});

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
              return _VideoLargeCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _VideoLargeCard extends StatelessWidget {
  final VideoItem item;

  const _VideoLargeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156.maxWidth,
      height: 163.maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.radius),
            child: Image.asset(
              item.imageUrl,
              width: 156.maxWidth,
              height: 113.maxHeight,
              fit: BoxFit.cover,
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
              CircleAvatar(
                radius: 8.radius,
                backgroundImage: AssetImage(item.creatorImageUrl),
              ),
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
    );
  }
}

