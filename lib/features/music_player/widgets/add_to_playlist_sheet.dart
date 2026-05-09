import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/music_player/models/playlist_summary.dart';
import 'package:muxify/features/music_player/providers/music_player_interaction_provider.dart';

/// Modal bottom sheet that lets the user pick one of their playlists to add
/// the current track to, or create a new playlist that's seeded with the
/// track. Loads playlists lazily from the backend on open.
class AddToPlaylistSheet extends StatefulWidget {
  final String trackId;
  final String trackTitle;
  final MusicPlayerInteractionProvider interaction;

  const AddToPlaylistSheet({
    super.key,
    required this.trackId,
    required this.trackTitle,
    required this.interaction,
  });

  static Future<void> show(
    BuildContext context, {
    required String trackId,
    required String trackTitle,
    required MusicPlayerInteractionProvider interaction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToPlaylistSheet(
        trackId: trackId,
        trackTitle: trackTitle,
        interaction: interaction,
      ),
    );
  }

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  late Future<List<PlaylistSummary>> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = widget.interaction.getMyPlaylists();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.interaction.getMyPlaylists();
    });
  }

  Future<void> _addToExisting(PlaylistSummary playlist) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.interaction.addTrackToPlaylist(
        playlistId: playlist.id,
        trackId: widget.trackId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await AppToast.showInfo('Added to ${playlist.name}');
    } catch (e) {
      if (!mounted) return;
      await AppToast.showError('Could not add to playlist: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createAndAdd() async {
    if (_busy) return;
    final name = await _promptName(context);
    if (name == null || name.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final created = await widget.interaction.createPlaylistWithTrack(
        name: name.trim(),
        trackId: widget.trackId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await AppToast.showInfo('Added to ${created.name}');
    } catch (e) {
      if (!mounted) return;
      await AppToast.showError('Could not create playlist: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _promptName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.modalBackground,
          title: Text(
            'New playlist',
            style: AppTextStyles.heading2.copyWith(color: AppColors.text),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.modalCancelButtonBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.radius)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            8.column,
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            16.column,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.padding),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add to playlist',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.text,
                            fontSize: 20.font,
                          ),
                        ),
                        4.column,
                        Text(
                          widget.trackTitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            16.column,
            _buildCreateRow(),
            Divider(
              color: AppColors.text.withValues(alpha: 0.08),
              height: 1,
            ),
            Flexible(
              child: FutureBuilder<List<PlaylistSummary>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.buttonColor,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Could not load your playlists.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.text.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          12.column,
                          OutlinedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final playlists = snapshot.data ?? const <PlaylistSummary>[];
                  if (playlists.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'You don’t have any playlists yet.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.padding,
                      vertical: 8.padding,
                    ),
                    itemCount: playlists.length,
                    separatorBuilder: (_, __) => 4.column,
                    itemBuilder: (_, i) => _buildPlaylistTile(playlists[i]),
                  );
                },
              ),
            ),
            16.column,
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRow() {
    return ListTile(
      onTap: _busy ? null : _createAndAdd,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.modalCancelButtonBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.text.withValues(alpha: 0.85),
        ),
      ),
      title: Text(
        'Create new playlist',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Start a new playlist with this song',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.text.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(PlaylistSummary playlist) {
    return ListTile(
      onTap: _busy ? null : () => _addToExisting(playlist),
      leading: _buildCover(playlist.coverImageUrl),
      title: Text(
        playlist.name,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.trackCount} ${playlist.trackCount == 1 ? "track" : "tracks"}',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.text.withValues(alpha: 0.5),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.text.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildCover(String? url) {
    final fallback = Container(
      color: AppColors.modalCancelButtonBackground,
      child: Icon(
        Icons.music_note,
        color: AppColors.text.withValues(alpha: 0.4),
      ),
    );
    if (url == null || url.trim().isEmpty) {
      return _wrapCover(fallback);
    }
    return _wrapCover(
      CachedNetworkImage(
        imageUrl: ApiConstants.resolvePublicUrl(url),
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppColors.modalCancelButtonBackground,
        ),
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _wrapCover(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 48, height: 48, child: child),
    );
  }
}
