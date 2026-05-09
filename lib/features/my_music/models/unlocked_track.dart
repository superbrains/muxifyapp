import 'package:muxify/features/audio_playback/models/track.dart' as audio;

/// Mirror of the backend `UnlockedContentDto` (track variant), enriched with
/// artist + genre so the Library can group by either.
class UnlockedTrack {
  final String id;
  final String title;
  final String? artistId;
  final String artistName;
  final String? genreId;
  final String? genreName;
  final String? coverArtUrl;
  final int durationSeconds;
  final int unlockCostCoins;
  final DateTime? unlockedAt;

  const UnlockedTrack({
    required this.id,
    required this.title,
    required this.artistName,
    this.artistId,
    this.genreId,
    this.genreName,
    this.coverArtUrl,
    this.durationSeconds = 0,
    this.unlockCostCoins = 0,
    this.unlockedAt,
  });

  /// Convert to the audio playback Track. Stream URL is intentionally null —
  /// the existing `StreamUrlResolver` (wired in `AudioProvider`) lazily fetches
  /// the signed URL via `/content/tracks/{id}/stream` when playback starts.
  audio.Track toPlaybackTrack() => audio.Track(
        id: id,
        title: title,
        artist: artistName,
        artistId: artistId,
        artworkUrl: coverArtUrl,
        isUnlocked: true,
      );

  factory UnlockedTrack.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic v) {
      if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return UnlockedTrack(
      id: (json['contentId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artistId: json['artistId']?.toString(),
      artistName: (json['artistName'] ?? '').toString(),
      genreId: json['genreId']?.toString(),
      genreName: json['genreName'] as String?,
      coverArtUrl: json['coverArtUrl'] as String?,
      durationSeconds: parseInt(json['durationSeconds']),
      unlockCostCoins: parseInt(json['unlockCostCoins']),
      unlockedAt: parseDate(json['unlockedAt']),
    );
  }
}
