import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/utils/release_playback_helper.dart';
import 'package:muxify/features/artist_profile/widgets/custom_app_bar_widget.dart';
import 'package:muxify/features/artist_profile/widgets/songs_list_widget.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Shows a single album's header and its songs. The track list is built from
/// the artist's already-loaded tracks (which carry an `albumId`), so it needs
/// no dedicated album-tracks endpoint.
class AlbumDetailsScreen extends StatelessWidget {
  final String albumId;
  final String title;
  final String artistName;
  final String artistId;
  final String? coverImageUrl;
  final String? year;

  const AlbumDetailsScreen({
    super.key,
    required this.albumId,
    required this.title,
    required this.artistName,
    required this.artistId,
    this.coverImageUrl,
    this.year,
  });

  List<NewReleaseItem> _albumTracks(ArtistProfileProvider provider) {
    final id = albumId.trim();
    if (id.isEmpty) return const [];
    return provider.tracks
        .where((t) => t.albumId.trim() == id)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarWidget(title: title.isEmpty ? 'Album' : title),
      body: Consumer<ArtistProfileProvider>(
        builder: (context, provider, _) {
          final tracks = _albumTracks(provider);
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildAlbumHeader(context, tracks),
                30.column,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.padding),
                  child: tracks.isEmpty
                      ? _buildEmpty(provider.isLoadingTracks)
                      : SongsListWidget(
                          songs: tracks
                              .map((t) => t.toGenreSongItem())
                              .toList(growable: false),
                          onSongTap: (song) => _openTrack(context, tracks, song.id),
                          onPlayUnlockTap: (song) =>
                              _openTrack(context, tracks, song.id),
                          onMenuTap: (song) {},
                        ),
                ),
                40.column,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 120.maxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(
          color: AppColors.text.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Text(
        isLoading ? 'Loading songs…' : 'No songs available for this album yet.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.font,
          color: AppColors.text.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _openTrack(
    BuildContext context,
    List<NewReleaseItem> tracks,
    String trackId,
  ) async {
    final release = tracks.firstWhere(
      (t) => t.id == trackId,
      orElse: () => tracks.first,
    );
    await ReleasePlaybackHelper.openFromRelease(
      context,
      release: release,
      albumName: title.isEmpty ? 'Album' : title,
      artistId: artistId,
    );
  }

  Future<void> _playAlbum(
    BuildContext context,
    List<NewReleaseItem> tracks,
  ) async {
    if (tracks.isEmpty) {
      await AppToast.showInfo('No songs to play yet.');
      return;
    }
    final queue = tracks
        .map(
          (r) => Track(
            id: r.id,
            title: r.title,
            artist: r.artist,
            artistId: artistId,
            albumName: title.isEmpty ? 'Album' : title,
            artworkUrl: r.coverImageUrl,
            isUnlocked: r.isUnlocked || r.unlockCostCoins == 0,
            unlockCostCoins: r.unlockCostCoins,
          ),
        )
        .toList(growable: false);
    _openTrack(context, tracks, tracks.first.id);
    if (context.mounted) {
      await context.read<AudioProvider>().loadAndPlay(queue);
    }
  }

  Widget _buildAlbumHeader(BuildContext context, List<NewReleaseItem> tracks) {
    return Container(
      padding: EdgeInsets.all(20.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          transform: const GradientRotation(1.5),
          colors: [
            AppColors.playlistGradientStart,
            AppColors.playlistGradientStart.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0, 0.4, 0.8],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art
          SizedBox(
            width: 159.maxWidth,
            height: 159.buttonHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: _buildArtwork(),
            ),
          ),
          16.row,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Album' : title,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 30.font,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.75),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.column,
                Text(
                  artistName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 18.font,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((year ?? '').trim().isNotEmpty) ...[
                  4.column,
                  Text(
                    year!.trim(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.font,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                16.column,
                // Play the whole album as one queue.
                GestureDetector(
                  onTap: () => _playAlbum(context, tracks),
                  child: Container(
                    height: 44.maxHeight,
                    padding: EdgeInsets.symmetric(horizontal: 22.padding),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(22.radius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/pngs/play.png',
                          width: 18.icon,
                          height: 18.icon,
                        ),
                        8.row,
                        Text(
                          'Play',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16.font,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
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

  Widget _buildArtwork() {
    final url = (coverImageUrl ?? '').trim();
    final placeholder = Image.asset(
      'assets/pngs/follows.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
    if (url.isEmpty) return placeholder;
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return AuthNetworkImage(
      path: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: placeholder,
      errorWidget: placeholder,
    );
  }
}
