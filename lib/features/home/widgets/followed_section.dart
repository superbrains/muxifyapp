import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/widgets/followed_item_card.dart';
import 'package:muxify/features/home/widgets/section_header.dart';

class FollowedSection extends StatelessWidget {
  final String title;
  final List<FollowedItem> items;
  final VoidCallback? onSeeAll;

  const FollowedSection({
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
        // Section Header
        SectionHeader(title: title, onSeeAll: onSeeAll),

        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 24),
          // physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 columns
            crossAxisSpacing: 12.padding,
            mainAxisSpacing: 24.padding,
            childAspectRatio: 0.55, // More height for image + text content
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return FollowedItemCard(
              item: item,
              onTap: () {
                // TODO: Navigate to item detail
              },
            );
          },
        ),
      ],
    );
  }
}
