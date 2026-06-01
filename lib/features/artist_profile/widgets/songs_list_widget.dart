import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/shared/widgets/genre_song_item_widget.dart';

class SongsListWidget extends StatelessWidget {
  final List<GenreSongItem> songs;
  final Function(GenreSongItem) onSongTap;
  final Function(GenreSongItem) onPlayUnlockTap;
  final Function(GenreSongItem) onMenuTap;

  const SongsListWidget({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onPlayUnlockTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(height: 16.padding),
      itemBuilder: (context, index) {
        return GenreSongItemWidget(
          item: songs[index],
          isMoreButtonVisible: true,
          onMenueTap: () => onMenuTap(songs[index]),
          onTap: () => onSongTap(songs[index]),
          // Unlocked songs play immediately. Locked songs open the player,
          // where the real per-track unlock confirmation (actual coin cost +
          // ₦ value) is shown before any coins are spent.
          onPlayUnlockTap: () => onPlayUnlockTap(songs[index]),
        );
      },
    );
  }
}
