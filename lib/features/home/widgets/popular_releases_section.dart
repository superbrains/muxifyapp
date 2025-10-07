import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/widgets/new_release_card.dart';
import 'package:muxify/features/home/widgets/section_header.dart';

class PopularReleasesSection extends StatelessWidget {
  final String title;
  final List<NewReleaseItem> releases;
  final VoidCallback? onSeeAll;

  const PopularReleasesSection({
    super.key,
    required this.title,
    required this.releases,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        16.column,
        SizedBox(
          height: 145.buttonHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: releases.length,
            separatorBuilder: (context, index) => 15.row,
            itemBuilder: (context, index) {
              final release = releases[index];
              return NewReleaseCard(
                release: release,
                onTap: () {
                },
                onPlayTap: () {

                },
              );
            },
          ),
        ),
      ],
    );
  }
}
