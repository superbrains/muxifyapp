import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/recently_played_card.dart';
import 'package:shimmer/shimmer.dart';

class RecentlyPlayedSection extends StatelessWidget {
  final List<RecentlyPlayedItem> items;
  final bool isLoading;

  const RecentlyPlayedSection({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Recently Played',
          onSeeAll: () {
            HapticFeedback.lightImpact();
            context.push(AppRouter.statistics);
          },
        ),
        16.column,
        SizedBox(
          height: 120.buttonHeight,
          child: isLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => 12.row,
                  itemBuilder: (context, index) => const _RecentlyPlayedShimmerCard(),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => 12.row,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return RecentlyPlayedCard(item: item, onTap: () {});
                  },
                ),
        ),
      ],
    );
  }
}

class _RecentlyPlayedShimmerCard extends StatelessWidget {
  const _RecentlyPlayedShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3A3A3A),
      child: Column(
        children: [
          Container(
            width: 80.buttonHeight,
            height: 80.buttonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.radius),
            ),
          ),
          8.column,
          Container(
            width: 72.maxWidth,
            height: 14.buttonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.radius),
            ),
          ),
        ],
      ),
    );
  }
}
