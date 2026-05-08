import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/widgets/followed_item_card.dart';
import 'package:muxify/features/home/widgets/section_header.dart';

class FollowedSection extends StatelessWidget {
  final String title;
  final List<FollowedItem> items;
  final VoidCallback? onSeeAll;
  final void Function(FollowedItem item)? onItemTap;
  final bool isLoading;

  const FollowedSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12.padding,
            mainAxisSpacing: 24.padding,
            childAspectRatio: 0.55,
          ),
          itemCount: isLoading ? 8 : items.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8.radius),
                ),
              );
            }
            final item = items[index];
            return FollowedItemCard(
              item: item,
              onTap: () => onItemTap?.call(item),
            );
          },
        ),
      ],
    );
  }
}
