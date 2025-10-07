import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/album_item.dart';
import 'package:muxify/features/home/widgets/section_header.dart';
import 'package:muxify/features/home/widgets/album_card.dart';

class FeaturedAlbumsSection extends StatelessWidget {
  final List<AlbumItem> albums;
  final String title;

  const FeaturedAlbumsSection({
    super.key,
    required this.albums,
    this.title = 'Featured Albums',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to featured albums full list
          },
        ),
        16.column,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.padding,
            mainAxisSpacing: 12.padding,
            childAspectRatio: 0.75,
          ),
          itemCount: albums.length > 4 ? 4 : albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return AlbumCard(
              album: album,
              onTap: () {
                // TODO: Navigate to album detail
              },
            );
          },
        ),
      ],
    );
  }
}
