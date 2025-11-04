import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';

class VideoFollowedSection extends StatelessWidget {
  final String title;
  final List<VideoItem> items;
  final VoidCallback? onSeeAll;

  const VideoFollowedSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        16.column,
        Padding(
          padding: EdgeInsets.only(right: 24.padding),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.padding,
              mainAxisSpacing: 16.padding,
              childAspectRatio: 0.85.maxHeight,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _VideoFollowedCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _VideoFollowedCard extends StatelessWidget {
  final VideoItem item;

  const _VideoFollowedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
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

