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

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      songCount: json['songCount'] as String,
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tracks: (json['tracks'] as List<dynamic>)
          .map((track) => TrackItem.fromJson(track as Map<String, dynamic>))
          .toList(),
    );
  }
}
