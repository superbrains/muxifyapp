import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/recently_played_card.dart';

class RecentlyPlayedSection extends StatelessWidget {
  final List<RecentlyPlayedItem> items;

  const RecentlyPlayedSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Recently Played',
          onSeeAll: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to recently played full list
          },
        ),
        16.column,
        SizedBox(
          height: 120.buttonHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => 12.row,
            itemBuilder: (context, index) {
              final item = items[index];
              return RecentlyPlayedCard(
                item: item,
                onTap: () {
                  // TODO: Navigate to album/playlist detail
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
