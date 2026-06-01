import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/spotlight_tab.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/widgets/spotlight_detail_card.dart';
import 'package:muxify/features/home/widgets/spotlight_period_toggle.dart';

class SpotlightSection extends StatelessWidget {
  final List<SpotlightTab> tabs;
  final String selectedTabId;
  final Function(String) onTabChanged;
  final List<SpotlightItem> items;
  final VoidCallback? onSeeAll;
  final void Function(SpotlightItem item)? onItemTap;
  final void Function(SpotlightItem item)? onUnlockTap;
  final bool isLoading;

  /// Period toggle for the gift-leaderboard tabs; hidden on the curated tab.
  final bool showPeriodToggle;
  final String selectedPeriod; // 'week' | 'all'
  final ValueChanged<String>? onPeriodChanged;

  const SpotlightSection({
    super.key,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabChanged,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
    this.onUnlockTap,
    this.isLoading = false,
    this.showPeriodToggle = false,
    this.selectedPeriod = 'week',
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryTabsSection(
          categories: tabs
              .map(
                (tab) =>
                    CategoryTab(id: tab.id, title: tab.title, icon: tab.icon),
              )
              .toList(),
          selectedCategoryId: selectedTabId,
          onCategoryChanged: onTabChanged,
        ),
        if (showPeriodToggle && onPeriodChanged != null) ...[
          16.column,
          Padding(
            padding: EdgeInsets.only(right: 16.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SpotlightPeriodToggle(
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: onPeriodChanged!,
                ),
              ],
            ),
          ),
        ],
        24.column,
        if (isLoading)
          Container(
            height: 200,
            margin: EdgeInsets.only(right: 16.padding),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12.radius),
            ),
          )
        else
          ...items.map(
            (item) => SpotlightDetailCard(
              item: item,
              onTap: () => onItemTap?.call(item),
              onUnlockTap: () => onUnlockTap?.call(item),
            ),
          ),
      ],
    );
  }
}
