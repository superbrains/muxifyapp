import 'package:flutter/material.dart';

import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/widgets/spotlight_detail_card.dart';
import 'package:muxify/features/home/widgets/spotlight_leaderboard_row.dart';

/// Renders the body of a spotlight tab: curated items use the big banner
/// [SpotlightDetailCard]; gift-leaderboard items use the compact, chart-style
/// [SpotlightLeaderboardRow]. Keeps the two section widgets (music + video)
/// visually identical.
class SpotlightItemsView extends StatelessWidget {
  final List<SpotlightItem> items;
  final bool isLoading;

  /// True for the gift-leaderboard tabs (compact rows); false for the curated
  /// Spotlight tab (banner cards) — drives the loading skeleton shape.
  final bool isLeaderboard;

  final void Function(SpotlightItem item)? onItemTap;
  final void Function(SpotlightItem item)? onUnlockTap;

  const SpotlightItemsView({
    super.key,
    required this.items,
    required this.isLoading,
    required this.isLeaderboard,
    this.onItemTap,
    this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return isLeaderboard ? _leaderboardSkeleton() : _bannerSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          _buildItem(items[i], showDivider: isLeaderboard && i < items.length - 1),
      ],
    );
  }

  Widget _buildItem(SpotlightItem item, {required bool showDivider}) {
    if (item.kind == SpotlightKind.curated) {
      return SpotlightDetailCard(
        item: item,
        onTap: () => onItemTap?.call(item),
        onUnlockTap: () => onUnlockTap?.call(item),
      );
    }
    return Column(
      children: [
        SpotlightLeaderboardRow(
          item: item,
          onTap: () => onItemTap?.call(item),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 88.padding, right: 16.padding),
            child: Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFF1E1E1E),
            ),
          ),
      ],
    );
  }

  Widget _bannerSkeleton() {
    return Container(
      height: 200,
      margin: EdgeInsets.only(right: 16.padding),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.radius),
      ),
    );
  }

  Widget _leaderboardSkeleton() {
    return Column(
      children: List.generate(4, (_) => _skeletonRow()),
    );
  }

  Widget _skeletonRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.padding, horizontal: 16.padding),
      child: Row(
        children: [
          SizedBox(width: 22.maxWidth),
          12.row,
          Container(
            width: 54.maxWidth,
            height: 54.maxWidth,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10.radius),
            ),
          ),
          14.row,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.maxHeight,
                  width: 140.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(6.radius),
                  ),
                ),
                8.column,
                Container(
                  height: 10.maxHeight,
                  width: 80.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(6.radius),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
