import 'package:muxify/features/home/data/feed_dtos.dart';

class NewReleaseItem {
  final String id;
  final String albumName;
  final String artistName;
  final String? imageUrl;

  NewReleaseItem({
    required this.id,
    required this.albumName,
    required this.artistName,
    this.imageUrl,
  });

  /// Maps the backend `FeedTrackDto`. The home "Popular New Releases" section
  /// shows tracks (not albums); we display the track title in the album slot
  /// because the card layout has only two text rows.
  factory NewReleaseItem.fromFeedTrack(FeedTrackDto dto) {
    return NewReleaseItem(
      id: dto.id,
      albumName: dto.title,
      artistName: dto.artistName,
      imageUrl: dto.coverArtUrl,
    );
  }
}
