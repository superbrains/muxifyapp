import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/video_thumbnail_card.dart';

class RecentlyPlayedVideosSection extends StatelessWidget {
  final List<VideoItem> items;

  const RecentlyPlayedVideosSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Recently Played',
          onSeeAll: () {
            HapticFeedback.lightImpact();
            context.push('${AppRouter.statistics}?mediaType=Videos');
          },
        ),
        15.column,
        SizedBox(
          height: 120.buttonHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => 15.row,
            itemBuilder: (context, index) {
              final item = items[index];
              return VideoThumbnailCard(item: item, onTap: () {});
            },
          ),
        ),
      ],
    );
  }
}
