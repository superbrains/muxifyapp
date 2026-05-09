import 'package:muxify/features/my_music/models/local_playlist_track.dart';

/// A user-created playlist persisted on the device. The [tracks] list is the
/// playback order — earliest at index 0.
class LocalPlaylist {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<LocalPlaylistTrack> tracks;

  const LocalPlaylist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.tracks = const [],
  });

  int get trackCount => tracks.length;

  Duration get totalDuration => Duration(
        seconds: tracks.fold<int>(0, (sum, t) => sum + t.durationSeconds),
      );

  LocalPlaylist copyWith({
    String? name,
    DateTime? updatedAt,
    List<LocalPlaylistTrack>? tracks,
  }) =>
      LocalPlaylist(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        tracks: tracks ?? this.tracks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tracks': tracks.map((t) => t.toJson()).toList(growable: false),
      };

  factory LocalPlaylist.fromJson(Map<String, dynamic> json) {
    final tracksRaw = json['tracks'];
    final parsedTracks = <LocalPlaylistTrack>[];
    if (tracksRaw is List) {
      for (final item in tracksRaw) {
        if (item is Map<String, dynamic>) {
          parsedTracks.add(LocalPlaylistTrack.fromJson(item));
        } else if (item is Map) {
          parsedTracks
              .add(LocalPlaylistTrack.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return LocalPlaylist(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      tracks: parsedTracks,
    );
  }
}
