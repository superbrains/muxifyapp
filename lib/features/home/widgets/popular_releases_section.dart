import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/widgets/new_release_card.dart';
import 'package:muxify/features/home/widgets/section_header.dart';

class PopularReleasesSection extends StatelessWidget {
  final String title;
  final List<NewReleaseItem> releases;
  final VoidCallback? onSeeAll;
  final void Function(NewReleaseItem item)? onItemTap;
  final bool isLoading;

  const PopularReleasesSection({
    super.key,
    required this.title,
    required this.releases,
    this.onSeeAll,
    this.onItemTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && releases.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        16.column,
        SizedBox(
          height: 145.buttonHeight,
          child: isLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => 15.row,
                  itemBuilder: (_, __) => _PopularReleaseShimmer(),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: releases.length,
                  separatorBuilder: (context, index) => 15.row,
                  itemBuilder: (context, index) {
                    final release = releases[index];
                    return NewReleaseCard(
                      release: release,
                      onTap: () => onItemTap?.call(release),
                      onPlayTap: () => onItemTap?.call(release),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PopularReleaseShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135.maxWidth,
      height: 145.buttonHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(13.radius),
      ),
    );
  }
}
