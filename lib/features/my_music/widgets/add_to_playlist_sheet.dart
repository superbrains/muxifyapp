import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/my_music/models/local_playlist.dart';
import 'package:muxify/features/my_music/models/local_playlist_track.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';
import 'package:muxify/features/my_music/widgets/create_playlist_sheet.dart';
import 'package:muxify/features/my_music/widgets/playlist_cover_mosaic.dart';

/// Bottom sheet that lets the user add a single track to one of their local
/// playlists, or create a new playlist on the spot. Eligibility is enforced
/// by [LocalPlaylistsProvider.addTrack]; we surface failures via a toast.
class AddToPlaylistSheet extends StatelessWidget {
  const AddToPlaylistSheet({
    super.key,
    required this.track,
    required this.isEligible,
  });

  final LocalPlaylistTrack track;

  /// True when the source track is free or the user owns it. When false the
  /// sheet still renders, but the action rows are disabled with an explainer.
  final bool isEligible;

  static Future<void> show(
    BuildContext context, {
    required LocalPlaylistTrack track,
    required bool isEligible,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AddToPlaylistSheet(track: track, isEligible: isEligible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.headerGradient.withValues(alpha: 0.45),
                AppColors.background,
              ],
            ),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28.radius)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.padding,
                12.padding,
                20.padding,
                16.padding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44.maxWidth,
                      height: 4.maxHeight,
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4.radius),
                      ),
                    ),
                  ),
                  16.column,
                  Text(
                    'Add to playlist',
                    style: AppTextStyles.heading2.copyWith(fontSize: 22.font),
                  ),
                  4.column,
                  Text(
                    track.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.font,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  20.column,
                  if (!isEligible)
                    Container(
                      padding: EdgeInsets.all(14.padding),
                      decoration: BoxDecoration(
                        color: AppColors.headerGradient.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14.radius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: AppColors.text,
                            size: 22.icon,
                          ),
                          12.row,
                          Expanded(
                            child: Text(
                              'Unlock this track first to add it to a playlist.',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13.font),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _CreateRow(
                      onPressed: () => _handleCreate(context),
                    ),
                  16.column,
                  Flexible(child: _PlaylistList(track: track, enabled: isEligible)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    final provider = context.read<LocalPlaylistsProvider>();
    final name = await CreatePlaylistSheet.show(context);
    if (name == null || name.trim().isEmpty) return;
    final playlist = await provider.create(name);
    if (!context.mounted) return;
    await _addAndDismiss(context, provider, playlist.id);
  }

  Future<void> _addAndDismiss(
    BuildContext context,
    LocalPlaylistsProvider provider,
    String playlistId,
  ) async {
    try {
      await provider.addTrack(playlistId, track);
      if (!context.mounted) return;
      HapticFeedback.lightImpact();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Added to playlist',
        gravity: ToastGravity.BOTTOM,
      );
    } on IneligibleTrackException catch (e) {
      Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.BOTTOM);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Could not add. Try again.',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.radius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.padding,
          vertical: 12.padding,
        ),
        decoration: BoxDecoration(
          color: AppColors.glassyDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(
            color: AppColors.buttonColor.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44.maxHeight,
              width: 44.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(12.radius),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.text,
                size: 24.icon,
              ),
            ),
            14.row,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New playlist',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15.font,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  2.column,
                  Text(
                    'Create one and add this track',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.font,
                      color: AppColors.text.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.icon,
              color: AppColors.text.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({required this.track, required this.enabled});

  final LocalPlaylistTrack track;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocalPlaylistsProvider>();
    final playlists = provider.playlists;

    if (playlists.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.padding),
        child: Text(
          'No playlists yet — create your first one above.',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.font,
            color: AppColors.text.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: playlists.length,
      separatorBuilder: (_, __) => 8.column,
      itemBuilder: (context, i) {
        final p = playlists[i];
        final alreadyIn = p.tracks.any((t) => t.trackId == track.trackId);
        return _PlaylistRow(
          playlist: p,
          alreadyIn: alreadyIn,
          enabled: enabled && !alreadyIn,
          onTap: () async {
            final sheetCtx = context;
            try {
              await provider.addTrack(p.id, track);
              if (!sheetCtx.mounted) return;
              HapticFeedback.lightImpact();
              Navigator.of(sheetCtx).pop();
              Fluttertoast.showToast(
                msg: 'Added to "${p.name}"',
                gravity: ToastGravity.BOTTOM,
              );
            } on IneligibleTrackException catch (e) {
              Fluttertoast.showToast(
                  msg: e.message, gravity: ToastGravity.BOTTOM);
            } catch (e) {
              Fluttertoast.showToast(
                msg: 'Could not add. Try again.',
                gravity: ToastGravity.BOTTOM,
              );
            }
          },
        );
      },
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({
    required this.playlist,
    required this.alreadyIn,
    required this.enabled,
    required this.onTap,
  });

  final LocalPlaylist playlist;
  final bool alreadyIn;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14.radius),
        child: Container(
          padding: EdgeInsets.all(10.padding),
          decoration: BoxDecoration(
            color: AppColors.glassyDark.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14.radius),
          ),
          child: Row(
            children: [
              PlaylistCoverMosaic(playlist: playlist, size: 44.maxWidth),
              12.row,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playlist.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15.font,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.column,
                    Text(
                      _subtitle(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.font,
                        color: AppColors.text.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (alreadyIn)
                Padding(
                  padding: EdgeInsets.only(right: 8.padding),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 22.icon,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    if (alreadyIn) return 'Already in this playlist';
    final count = playlist.trackCount;
    if (count == 0) return 'Empty playlist';
    return '$count song${count == 1 ? '' : 's'}';
  }
}
