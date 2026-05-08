import 'package:muxify/features/home/data/feed_dtos.dart';

class FollowedItem {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? imageUrl;
  final bool isUnlocked;

  FollowedItem({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.imageUrl,
    this.isUnlocked = false,
  });

  /// `id` is the track id — used to resolve a stream URL when the user taps
  /// the card.
  factory FollowedItem.fromFeedTrack(FeedTrackDto dto) {
    return FollowedItem(
      id: dto.id,
      title: dto.title,
      artist: dto.artistName,
      artistId: dto.artistId,
      imageUrl: dto.coverArtUrl,
      isUnlocked: dto.isUnlocked,
    );
  }
}
