import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
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

class VideoFollowedSection extends StatelessWidget {
  final String title;
  final List<VideoItem> items;
  final VoidCallback? onSeeAll;
  final void Function(VideoItem item)? onItemTap;

  const VideoFollowedSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
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
              return _VideoFollowedCard(
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

class _VideoFollowedCard extends StatelessWidget {
  final VideoItem item;
  final VoidCallback? onTap;

  const _VideoFollowedCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap == null) return;
        HapticFeedback.lightImpact();
        onTap!();
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
              color: AppColors.text.withValues(alpha: 0.75),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          2.column,
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
    );
  }
}
