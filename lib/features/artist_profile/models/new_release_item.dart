import 'package:muxify/features/artist_profile/models/artist_albums_response.dart';
import 'package:muxify/features/artist_profile/models/artist_new_releases_response.dart';
import 'package:muxify/features/artist_profile/models/artist_tracks_response.dart';
import 'package:muxify/features/artist_profile/models/artist_videos_response.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/features/home/models/album_item.dart';

class NewReleaseItem {
  final String id;
  final String type;
  final String title;
  final String artist;
  final String coverImageUrl;
  final int unlockCostCoins;
  final DateTime? releaseDate;
  bool isUnlocked;

  NewReleaseItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
    this.type = 'track',
    this.unlockCostCoins = 0,
    this.isUnlocked = false,
    this.releaseDate,
  });

  factory NewReleaseItem.fromArtistNewReleaseItem(
    ArtistNewReleaseItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      type: item.type.isEmpty ? 'track' : item.type,
      title: item.title,
      artist: artistName,
      coverImageUrl: item.imageUrl,
      releaseDate: item.releaseDate,
      unlockCostCoins: 0,
      isUnlocked: false,
    );
  }

  factory NewReleaseItem.fromArtistAlbumItem(
    ArtistAlbumItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      type: 'album',
      title: item.title,
      artist: artistName,
      coverImageUrl: item.coverArtUrl,
      releaseDate: item.releaseDate,
      unlockCostCoins: 0,
      isUnlocked: false,
    );
  }

  factory NewReleaseItem.fromArtistTrackItem(
    ArtistTrackItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      type: 'track',
      title: item.title,
      artist: artistName,
      coverImageUrl: item.coverArtUrl,
      releaseDate: item.releaseDate,
      unlockCostCoins: item.unlockCostCoins,
      isUnlocked: item.isUnlocked,
    );
  }

  factory NewReleaseItem.fromArtistVideoItem(
    ArtistVideoItem item,
    String artistName,
  ) {
    return NewReleaseItem(
      id: item.id,
      type: 'video',
      title: item.title,
      artist: artistName,
      coverImageUrl: item.thumbnailUrl,
      releaseDate: item.createdAt,
      unlockCostCoins: item.unlockCostCoins,
      isUnlocked: item.isUnlocked,
    );
  }

  GenreSongItem toGenreSongItem() {
    return GenreSongItem(
      id: id,
      title: title,
      artist: artist,
      albumArtUrl: coverImageUrl,
      isUnlocked: isUnlocked,
    );
  }

  AlbumItem toAlbumItem({String giftCount = '0'}) {
    return AlbumItem(
      id: id,
      title: title,
      artist: artist,
      giftCount: giftCount,
      albumArtUrl: coverImageUrl,
    );
  }

  NewReleaseItem copyWith({
    String? id,
    String? type,
    String? title,
    String? artist,
    String? coverImageUrl,
    int? unlockCostCoins,
    bool? isUnlocked,
    DateTime? releaseDate,
  }) {
    return NewReleaseItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      unlockCostCoins: unlockCostCoins ?? this.unlockCostCoins,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }
}
