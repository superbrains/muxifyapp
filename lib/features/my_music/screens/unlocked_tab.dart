import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/my_music/models/local_playlist_track.dart';
import 'package:muxify/features/my_music/models/unlocked_track.dart';
import 'package:muxify/features/my_music/providers/library_provider.dart';
import 'package:muxify/features/my_music/widgets/add_to_playlist_sheet.dart';
import 'package:muxify/features/my_music/widgets/library_segmented_control.dart';
import 'package:muxify/features/my_music/widgets/my_music_track_row.dart';
import 'package:muxify/features/my_music/widgets/play_all_button.dart';

class UnlockedTab extends StatefulWidget {
  const UnlockedTab({super.key});

  @override
  State<UnlockedTab> createState() => _UnlockedTabState();
}

class _UnlockedTabState extends State<UnlockedTab> {
  LibraryGrouping _grouping = LibraryGrouping.all;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    if (!library.hasLoaded && library.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.buttonColor),
      );
    }

    if (library.error != null && library.tracks.isEmpty) {
      return _ErrorState(
        message: library.error!,
        onRetry: library.refresh,
      );
    }

    if (library.isEmpty) {
      return _EmptyState(
        onRefresh: library.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: library.refresh,
      color: AppColors.buttonColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20.padding,
          20.padding,
          20.padding,
          120.padding,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          PlayAllButton(
            subtitle:
                '${library.tracks.length} song${library.tracks.length == 1 ? '' : 's'}',
            onPressed: () => _playAll(library.tracks),
          ),
          18.column,
          LibrarySegmentedControl(
            value: _grouping,
            onChanged: (g) => setState(() => _grouping = g),
          ),
          22.column,
          ..._buildBody(library),
        ],
      ),
    );
  }

  List<Widget> _buildBody(LibraryProvider library) {
    switch (_grouping) {
      case LibraryGrouping.all:
        return _buildFlatList(library.tracks);
      case LibraryGrouping.byArtist:
        return _buildSections(library.byArtist);
      case LibraryGrouping.byGenre:
        return _buildSections(library.byGenre);
    }
  }

  List<Widget> _buildFlatList(List<UnlockedTrack> tracks) {
    return [
      for (var i = 0; i < tracks.length; i++) ...[
        if (i > 0) 4.column,
        _trackRow(tracks, i),
      ],
    ];
  }

  List<Widget> _buildSections(Map<String, List<UnlockedTrack>> groups) {
    final widgets = <Widget>[];
    final entries = groups.entries.toList(growable: false);
    for (var s = 0; s < entries.length; s++) {
      final entry = entries[s];
      if (s > 0) widgets.add(24.column);
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.padding, left: 4.padding),
          child: Text(
            entry.key,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              fontWeight: FontWeight.w700,
              color: AppColors.text.withValues(alpha: 0.85),
              letterSpacing: 0.4,
            ),
          ),
        ),
      );
      for (var i = 0; i < entry.value.length; i++) {
        if (i > 0) widgets.add(4.column);
        widgets.add(_trackRow(entry.value, i));
      }
    }
    return widgets;
  }

  Widget _trackRow(List<UnlockedTrack> tracks, int index) {
    final t = tracks[index];
    return MyMusicTrackRow(
      title: t.title,
      artist: t.artistName,
      coverArtUrl: t.coverArtUrl,
      durationSeconds: t.durationSeconds,
      trailing: MyMusicTrackTrailing.addToPlaylist,
      onTap: () => _playFrom(tracks, index),
      onTrailingTap: () => _openAddSheet(t),
    );
  }

  void _playAll(List<UnlockedTrack> tracks) {
    if (tracks.isEmpty) return;
    final audio = context.read<AudioProvider>();
    audio.loadAndPlay(
      tracks.map((t) => t.toPlaybackTrack()).toList(growable: false),
    );
  }

  void _playFrom(List<UnlockedTrack> tracks, int startIndex) {
    final audio = context.read<AudioProvider>();
    audio.loadAndPlay(
      tracks.map((t) => t.toPlaybackTrack()).toList(growable: false),
      startIndex: startIndex,
    );
  }

  void _openAddSheet(UnlockedTrack t) {
    AddToPlaylistSheet.show(
      context,
      track: LocalPlaylistTrack.fromUnlocked(t),
      isEligible: true,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.buttonColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          Center(
            child: Container(
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
                Icons.library_music_rounded,
                size: 64.icon,
                color: AppColors.text.withValues(alpha: 0.85),
              ),
            ),
          ),
          24.column,
          Center(
            child: Text(
              'Your Library is empty',
              style: AppTextStyles.heading2.copyWith(
                fontFamily: 'Luckiest Guy',
                fontSize: 22.font,
              ),
            ),
          ),
          8.column,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.padding),
            child: Text(
              'Unlock a song from the home feeds to start your collection — it shows up here for instant access.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.font,
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56.icon,
              color: AppColors.text.withValues(alpha: 0.55),
            ),
            14.column,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.font,
                color: AppColors.text.withValues(alpha: 0.7),
              ),
            ),
            18.column,
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
