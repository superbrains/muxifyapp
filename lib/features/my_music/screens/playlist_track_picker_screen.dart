import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/my_music/models/local_playlist_track.dart';
import 'package:muxify/features/my_music/models/playable_track.dart';
import 'package:muxify/features/my_music/providers/local_playlists_provider.dart';
import 'package:muxify/features/my_music/providers/playable_tracks_provider.dart';
import 'package:muxify/features/my_music/widgets/my_music_track_row.dart';

/// Track picker for adding songs to a local playlist. Source list is the
/// `/content/playable-tracks` endpoint, which already filters to free tracks
/// + the user's unlocked tracks — so anything visible here is eligible.
class PlaylistTrackPickerScreen extends StatefulWidget {
  const PlaylistTrackPickerScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistTrackPickerScreen> createState() =>
      _PlaylistTrackPickerScreenState();
}

class _PlaylistTrackPickerScreenState extends State<PlaylistTrackPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  final Map<String, PlayableTrack> _selectedById = <String, PlayableTrack>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PlayableTracksProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(PlayableTrack t) {
    setState(() {
      if (_selectedIds.contains(t.id)) {
        _selectedIds.remove(t.id);
        _selectedById.remove(t.id);
      } else {
        _selectedIds.add(t.id);
        _selectedById[t.id] = t;
      }
    });
  }

  Future<void> _confirm() async {
    if (_selectedIds.isEmpty || _saving) return;
    setState(() => _saving = true);

    final provider = context.read<LocalPlaylistsProvider>();
    var added = 0;
    var skipped = 0;
    for (final id in _selectedIds) {
      final t = _selectedById[id];
      if (t == null) continue;
      try {
        await provider.addTrack(
          widget.playlistId,
          LocalPlaylistTrack.fromPlayable(t),
        );
        added += 1;
      } on IneligibleTrackException {
        skipped += 1;
      } catch (_) {
        skipped += 1;
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: skipped > 0
          ? 'Added $added · skipped $skipped'
          : 'Added $added song${added == 1 ? '' : 's'}',
      gravity: ToastGravity.BOTTOM,
    );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final picker = context.watch<PlayableTracksProvider>();
    final existingIds = context
            .watch<LocalPlaylistsProvider>()
            .playlistById(widget.playlistId)
            ?.tracks
            .map((t) => t.trackId)
            .toSet() ??
        <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.headerGradient.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                12.column,
                _buildSearch(picker),
                14.column,
                Expanded(child: _buildList(picker, existingIds)),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding, vertical: 8.padding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) context.pop();
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
              child: Icon(
                Icons.close_rounded,
                size: 22.icon,
                color: AppColors.text,
              ),
            ),
          ),
          14.row,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add tracks',
                  style: AppTextStyles.heading2.copyWith(
                    fontFamily: 'Luckiest Guy',
                    fontSize: 24.font,
                  ),
                ),
                3.column,
                Text(
                  'Free songs and tracks you\'ve unlocked',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(PlayableTracksProvider picker) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Container(
        height: 48.maxHeight,
        padding: EdgeInsets.symmetric(horizontal: 14.padding),
        decoration: BoxDecoration(
          color: AppColors.glassyDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 22.icon,
              color: AppColors.text.withValues(alpha: 0.5),
            ),
            10.row,
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: picker.setSearch,
                cursorColor: AppColors.buttonColor,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.font),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by title or artist',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.font,
                    color: AppColors.text.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            if (picker.search.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  picker.setSearch('');
                },
                child: Icon(
                  Icons.clear_rounded,
                  size: 18.icon,
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(PlayableTracksProvider picker, Set<String> existingIds) {
    if (picker.isLoading && picker.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.buttonColor),
      );
    }

    if (picker.error != null && picker.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48.icon,
                color: AppColors.text.withValues(alpha: 0.55),
              ),
              12.column,
              Text(
                picker.error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.font),
              ),
              16.column,
              FilledButton(
                onPressed: picker.refresh,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (picker.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.padding),
          child: Text(
            picker.search.isEmpty
                ? 'Nothing to add yet — unlock songs or browse free tracks first.'
                : 'No tracks match "${picker.search}".',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.font,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20.padding,
        4.padding,
        20.padding,
        16.padding,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: picker.items.length,
      separatorBuilder: (_, __) => 4.column,
      itemBuilder: (context, i) {
        final t = picker.items[i];
        final alreadyIn = existingIds.contains(t.id);
        return Opacity(
          opacity: alreadyIn ? 0.5 : 1,
          child: MyMusicTrackRow(
            title: t.title,
            artist: t.artistName,
            coverArtUrl: t.coverArtUrl,
            durationSeconds: t.durationSeconds,
            subtitleSuffix: t.isFree ? 'FREE' : null,
            trailing: alreadyIn
                ? MyMusicTrackTrailing.none
                : MyMusicTrackTrailing.selectable,
            isSelected: _selectedIds.contains(t.id),
            onTap: alreadyIn ? () {} : () => _toggle(t),
            onTrailingTap: alreadyIn ? null : () => _toggle(t),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final n = _selectedIds.length;
    final disabled = n == 0 || _saving;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.padding,
          12.padding,
          20.padding,
          16.padding,
        ),
        child: SizedBox(
          height: 56.buttonHeight,
          child: FilledButton(
            onPressed: disabled ? null : _confirm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              disabledBackgroundColor:
                  AppColors.buttonColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.radius),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.text,
                    ),
                  )
                : Text(
                    n == 0
                        ? 'Select tracks to add'
                        : 'Add $n track${n == 1 ? '' : 's'}',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 16.font),
                  ),
          ),
        ),
      ),
    );
  }
}
