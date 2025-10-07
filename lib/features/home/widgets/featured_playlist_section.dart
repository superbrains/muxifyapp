import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/widgets/playlist_card.dart';

class FeaturedPlaylistSection extends StatelessWidget {
  final List<PlaylistItem> playlists;
  final VoidCallback? onSeeAll;

  const FeaturedPlaylistSection({
    super.key,

    required this.playlists,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 408.buttonHeight, // Adjust based on content
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: playlists.length,
            separatorBuilder: (context, index) => 18.row,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return SizedBox(
                width: 288.maxWidth, // Fixed width for each card
                child: PlaylistCard(
                  playlist: playlist,
                  onTap: () {
                    // TODO: Navigate to playlist detail
                  },
                  onPlayTap: () {
                    // TODO: Play playlist
                  },
                  onFavoriteTap: () {
                    // TODO: Toggle favorite
                  },
                  onMenuTap: () {
                    // TODO: Show playlist options
                  },
                  onSeeAllTap: () {
                    // TODO: Navigate to full playlist
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
