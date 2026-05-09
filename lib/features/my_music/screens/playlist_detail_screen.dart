import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/my_music/models/local_playlist.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';
import 'package:muxify/features/my_music/widgets/create_playlist_sheet.dart';
import 'package:muxify/features/my_music/widgets/my_music_track_row.dart';
import 'package:muxify/features/my_music/widgets/play_all_button.dart';
import 'package:muxify/features/my_music/widgets/playlist_cover_mosaic.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocalPlaylistsProvider>();
    final playlist = provider.playlistById(playlistId);

    if (playlist == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.text),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.padding),
            child: Text(
              'This playlist no longer exists.',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.font),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.headerGradient.withValues(alpha: 0.7),
                    AppColors.headerGradient.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _Header(playlist: playlist),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20.padding,
                    16.padding,
                    20.padding,
                    16.padding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PlayAllButton(
                      subtitle: _subtitle(playlist),
                      enabled: playlist.tracks.isNotEmpty,
                      onPressed: playlist.tracks.isEmpty
                          ? null
                          : () => _playAll(context, playlist),
                    ),
                  ),
                ),
                if (playlist.tracks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      onAddTracks: () => _openPicker(context, playlist),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.padding),
                    sliver: SliverList.separated(
                      itemCount: playlist.tracks.length,
                      separatorBuilder: (_, __) => 4.column,
                      itemBuilder: (context, i) {
                        final t = playlist.tracks[i];
                        return MyMusicTrackRow(
                          title: t.title,
                          artist: t.artist,
                          coverArtUrl: t.coverArtUrl,
                          durationSeconds: t.durationSeconds,
                          trailing: MyMusicTrackTrailing.remove,
                          onTap: () => _playFrom(context, playlist, i),
                          onTrailingTap: () =>
                              provider.removeTrack(playlist.id, t.trackId),
                        );
                      },
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 16.padding, bottom: 120.padding),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => _openPicker(context, playlist),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.buttonColor,
                        ),
                        label: Text(
                          'Add more tracks',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.font,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playAll(BuildContext context, LocalPlaylist playlist) {
    final audio = context.read<AudioProvider>();
    audio.loadAndPlay(
      playlist.tracks.map((t) => t.toPlaybackTrack()).toList(growable: false),
    );
  }

  void _playFrom(BuildContext context, LocalPlaylist playlist, int index) {
    final audio = context.read<AudioProvider>();
    audio.loadAndPlay(
      playlist.tracks.map((t) => t.toPlaybackTrack()).toList(growable: false),
      startIndex: index,
    );
  }

  void _openPicker(BuildContext context, LocalPlaylist playlist) {
    HapticFeedback.lightImpact();
    context.push(AppRouter.playlistAddTracksPath(playlist.id));
  }

  String _subtitle(LocalPlaylist playlist) {
    final count = playlist.tracks.length;
    if (count == 0) return 'No tracks yet';
    final mins = playlist.totalDuration.inMinutes;
    return '$count song${count == 1 ? '' : 's'} · ${mins == 0 ? '< 1' : mins} min';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.playlist});
  final LocalPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.padding, 8.padding, 20.padding, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                _RoundIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRouter.myMusic);
                    }
                  },
                ),
                const Spacer(),
                _RoundIcon(
                  icon: Icons.edit_rounded,
                  onTap: () => _renameDialog(context),
                ),
                10.row,
                _RoundIcon(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            22.column,
            Center(
              child: PlaylistCoverMosaic(
                playlist: playlist,
                size: 200.maxWidth,
                borderRadius: BorderRadius.circular(20.radius),
              ),
            ),
            18.column,
            Text(
              playlist.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                fontFamily: 'Luckiest Guy',
                fontSize: 28.font,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            6.column,
            Text(
              _label(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.font,
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label() {
    final count = playlist.trackCount;
    if (count == 0) return 'Local playlist · empty';
    final mins = playlist.totalDuration.inMinutes;
    return 'Local playlist · ${mins == 0 ? '< 1' : mins} min';
  }

  Future<void> _renameDialog(BuildContext context) async {
    final provider = context.read<LocalPlaylistsProvider>();
    final name = await CreatePlaylistSheet.show(
      context,
      initialName: playlist.name,
      title: 'Rename playlist',
    );
    if (name == null || name.trim().isEmpty) return;
    await provider.rename(playlist.id, name);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<LocalPlaylistsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modalBackground,
        title: Text(
          'Delete playlist?',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 17.font,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${playlist.name}" will be removed from this device. The songs themselves stay in your library.',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.font,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.buttonColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final name = playlist.name;
    await provider.delete(playlist.id);
    if (!context.mounted) return;
    Fluttertoast.showToast(msg: 'Deleted "$name"');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.myMusic);
    }
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 40.maxHeight,
        width: 40.maxWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassyLight.withValues(alpha: 0.6),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, size: 18.icon, color: AppColors.text),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTracks});
  final VoidCallback onAddTracks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.padding, vertical: 32.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          24.column,
          Icon(
            Icons.playlist_add_rounded,
            size: 64.icon,
            color: AppColors.text.withValues(alpha: 0.5),
          ),
          12.column,
          Text(
            'No tracks yet',
            style: AppTextStyles.heading2.copyWith(
              fontFamily: 'Luckiest Guy',
              fontSize: 22.font,
            ),
          ),
          8.column,
          Text(
            'Add free songs or tracks you\'ve unlocked. They\'ll play in order from here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.font,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          22.column,
          SizedBox(
            height: 48.buttonHeight,
            child: FilledButton.icon(
              onPressed: onAddTracks,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add tracks'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.radius),
                ),
                padding: EdgeInsets.symmetric(horizontal: 28.padding),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
