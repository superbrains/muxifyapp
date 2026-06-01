import 'package:muxify/features/home/data/feed_dtos.dart';
import 'package:muxify/features/home/models/track_item.dart';

class PlaylistItem {
  final String id;
  final String title;
  final String songCount;
  final String? imageUrl;
  final bool isFavorite;
  final List<TrackItem> tracks;

  PlaylistItem({
    required this.id,
    required this.title,
    required this.songCount,
    this.imageUrl,
    this.isFavorite = false,
    required this.tracks,
  });

  /// Builds a `PlaylistItem` from a backend featured playlist. Track previews
  /// are loaded lazily (`tracks` empty) — the carousel card shows the cover
  /// + title + count and a "See All" affordance.
  factory PlaylistItem.fromFeedPlaylist(FeedPlaylistDto dto) {
    return PlaylistItem(
      id: dto.id,
      title: dto.name,
      songCount: '${dto.trackCount} songs',
      imageUrl: dto.coverArtUrl,
      tracks: const [],
    );
  }

  /// Synthesises a category playlist from a list of tracks (used for the
  /// home Music tab category tabs: Trending / Hot Release / Top Chart /
  /// New Release). The `id` is a synthetic key; tracks are mapped from
  /// `FeedTrackDto`s so the inline list shows real titles + artists.
  factory PlaylistItem.fromCategory({
    required String id,
    required String title,
    required List<FeedTrackDto> sourceTracks,
    String? coverUrl,
  }) {
    final tracks = sourceTracks
        .map(
          (t) => TrackItem(
            id: t.id,
            title: t.title,
            artist: t.artistName,
            artistId: t.artistId,
            imageUrl: t.coverArtUrl,
            isUnlocked: t.isUnlocked,
            unlockCostCoins: t.unlockCostCoins,
          ),
        )
        .toList();
    return PlaylistItem(
      id: id,
      title: title,
      songCount: '${tracks.length} songs',
      imageUrl: coverUrl ?? sourceTracks.firstOrNull?.coverArtUrl,
      tracks: tracks,
    );
  }
}
