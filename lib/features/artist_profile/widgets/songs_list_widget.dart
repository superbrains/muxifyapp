import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/shared/widgets/genre_song_item_widget.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:provider/provider.dart';

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
          onPlayUnlockTap: () => _handleUnlockTap(context, songs[index]),
        );
      },
    );
  }

  void _handleUnlockTap(BuildContext context, GenreSongItem song) {
    final unlocked = context.read<UnlockedContentProvider>();
    if (unlocked.isUnlocked(song.id)) {
      onPlayUnlockTap(song);
      return;
    }
    _showUnlockModal(context, song);
  }

  void _showUnlockModal(BuildContext context, GenreSongItem song) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () {
            Navigator.of(context).pop();
          },
          onUnlockPremium: () {
            Navigator.of(context).pop();
            // Handle premium unlock
            onPlayUnlockTap(song);
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            // Handle free unlock
            onPlayUnlockTap(song);
          },
        );
      },
    );
  }
}
