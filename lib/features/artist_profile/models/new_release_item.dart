import 'package:muxify/features/artist_profile/models/artist_albums_response.dart';
import 'package:muxify/features/artist_profile/models/artist_new_releases_response.dart';
import 'package:muxify/features/artist_profile/models/artist_tracks_response.dart';

class NewReleaseItem {
  final String id;
  final String title;
  final String artist;
  final String coverImageUrl;
  bool isUnlocked;

  NewReleaseItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
    this.isUnlocked = false,
  });

  factory NewReleaseItem.fromArtistNewReleaseItem(
    ArtistNewReleaseItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      title: item.title,
      artist: artistName,
      coverImageUrl: item.imageUrl,
      isUnlocked:
          false, // Default to false, can be updated if API provides this
    );
  }

  factory NewReleaseItem.fromArtistAlbumItem(
    ArtistAlbumItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      title: item.title,
      artist: artistName,
      coverImageUrl: item.coverArtUrl,
      isUnlocked: false,
    );
  }

  factory NewReleaseItem.fromArtistTrackItem(
    ArtistTrackItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      title: item.title,
      artist: artistName,
      coverImageUrl: item.coverArtUrl,
      isUnlocked: item.isUnlocked,
    );
  }

  NewReleaseItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverImageUrl,
    bool? isUnlocked,
  }) {
    return NewReleaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
