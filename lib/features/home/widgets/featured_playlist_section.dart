import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/track_item.dart';
import 'package:muxify/features/home/widgets/playlist_card.dart';

class FeaturedPlaylistSection extends StatelessWidget {
  final List<PlaylistItem> playlists;
  final VoidCallback? onSeeAll;
  final void Function(PlaylistItem playlist)? onPlaylistTap;
  final void Function(TrackItem track)? onTrackTap;
  final bool isLoading;

  const FeaturedPlaylistSection({
    super.key,
    required this.playlists,
    this.onSeeAll,
    this.onPlaylistTap,
    this.onTrackTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && playlists.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 408.buttonHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: isLoading ? 3 : playlists.length,
            separatorBuilder: (context, index) => 18.row,
            itemBuilder: (context, index) {
              if (isLoading) {
                return Container(
                  width: 288.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16.radius),
                  ),
                );
              }
              final playlist = playlists[index];
              return SizedBox(
                width: 288.maxWidth,
                child: PlaylistCard(
                  playlist: playlist,
                  onTap: () => onPlaylistTap?.call(playlist),
                  onPlayTap: () => onPlaylistTap?.call(playlist),
                  onFavoriteTap: () {},
                  onMenuTap: () {},
                  onSeeAllTap: onSeeAll,
                  onTrackTap: onTrackTap,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
