import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/spotlight_tab.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/widgets/spotlight_detail_card.dart';

class SpotlightSection extends StatelessWidget {
  final List<SpotlightTab> tabs;
  final String selectedTabId;
  final Function(String) onTabChanged;
  final List<SpotlightItem> items;
  final VoidCallback? onSeeAll;

  const SpotlightSection({
    super.key,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabChanged,
    required this.items,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation Tabs
        CategoryTabsSection(
          categories: tabs
              .map(
                (tab) =>
                    CategoryTab(id: tab.id, title: tab.title, icon: tab.icon),
              )
              .toList(),
          selectedCategoryId: selectedTabId,
          onCategoryChanged: (categoryId) {
            onTabChanged(categoryId);
          },
        ),
        24.column,
        // Spotlight Detail Cards
        ...items.map(
          (item) => SpotlightDetailCard(
            item: item,
            onTap: () {
            },
            onUnlockTap: () {
            },
          ),
        ),
      ],
    );
  }
}
