import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/my_music/models/local_playlist.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';
import 'package:muxify/features/my_music/widgets/create_playlist_sheet.dart';
import 'package:muxify/features/my_music/widgets/playlist_cover_mosaic.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocalPlaylistsProvider>();

    if (!provider.hydrated) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.buttonColor),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20.padding,
        20.padding,
        20.padding,
        120.padding,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _CreateButton(onTap: () => _handleCreate(context)),
        20.column,
        if (provider.isEmpty)
          _EmptyState(onCreate: () => _handleCreate(context))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.padding,
              mainAxisSpacing: 14.padding,
              childAspectRatio: 0.78,
            ),
            itemCount: provider.playlists.length,
            itemBuilder: (context, i) {
              final p = provider.playlists[i];
              return _PlaylistCard(
                playlist: p,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(
                    AppRouter.playlistDetailPath(p.id),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    final provider = context.read<LocalPlaylistsProvider>();
    final name = await CreatePlaylistSheet.show(context);
    if (name == null || name.trim().isEmpty) return;
    final created = await provider.create(name);
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    context.push(AppRouter.playlistDetailPath(created.id));
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.radius),
      child: Container(
        padding: EdgeInsets.all(14.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.glassyDark.withValues(alpha: 0.85),
              AppColors.glassyLight.withValues(alpha: 0.65),
            ],
          ),
          borderRadius: BorderRadius.circular(20.radius),
          border: Border.all(
            color: AppColors.buttonColor.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 50.maxHeight,
              width: 50.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(14.radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonColor.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.text,
                size: 26.icon,
              ),
            ),
            14.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create playlist',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16.font,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  3.column,
                  Text(
                    'Mix free songs and your unlocked favorites',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.icon,
              color: AppColors.text.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onTap});
  final LocalPlaylist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PlaylistCoverMosaic(
                    playlist: playlist,
                    size: double.infinity,
                  ),
                ),
                Positioned(
                  right: 8.padding,
                  bottom: 8.padding,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.padding,
                      vertical: 4.padding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.shadowColor.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10.radius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 12.icon,
                          color: AppColors.text.withValues(alpha: 0.85),
                        ),
                        4.row,
                        Text(
                          '${playlist.trackCount}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.font,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          10.column,
          Text(
            playlist.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          2.column,
          Text(
            playlist.trackCount == 0
                ? 'Empty'
                : '${playlist.trackCount} song${playlist.trackCount == 1 ? '' : 's'}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.font,
              color: AppColors.text.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.padding),
      child: Column(
        children: [
          Container(
            height: 140.maxHeight,
            width: 140.maxWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.headerGradient,
                  AppColors.background,
                ],
              ),
            ),
            child: Icon(
              Icons.queue_music_rounded,
              size: 60.icon,
              color: AppColors.text.withValues(alpha: 0.85),
            ),
          ),
          22.column,
          Text(
            'Make your first mix',
            style: AppTextStyles.heading2.copyWith(
              fontFamily: 'Luckiest Guy',
              fontSize: 22.font,
            ),
          ),
          8.column,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.padding),
            child: Text(
              'Build a playlist with free tracks and the songs you\'ve unlocked.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.font,
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ),
          22.column,
          SizedBox(
            height: 48.buttonHeight,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create playlist'),
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
