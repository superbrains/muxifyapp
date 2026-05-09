import 'package:muxify/features/audio_playback/models/track.dart' as audio;

/// Mirror of the backend `PlayableTrackDto`. Represents a track the caller
/// is allowed to play (free OR personally unlocked) — the source of truth
/// for the local-playlist track picker.
class PlayableTrack {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? genreId;
  final String? genreName;
  final String? coverArtUrl;
  final int durationSeconds;
  final int unlockCostCoins;
  final bool isFree;
  final bool isUnlocked;

  const PlayableTrack({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.genreId,
    this.genreName,
    this.coverArtUrl,
    this.durationSeconds = 0,
    this.unlockCostCoins = 0,
    this.isFree = false,
    this.isUnlocked = false,
  });

  audio.Track toPlaybackTrack() => audio.Track(
        id: id,
        title: title,
        artist: artistName,
        artistId: artistId,
        artworkUrl: coverArtUrl,
        isUnlocked: true,
      );

  factory PlayableTrack.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return PlayableTrack(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artistId: (json['artistId'] ?? '').toString(),
      artistName: (json['artistName'] ?? '').toString(),
      genreId: json['genreId']?.toString(),
      genreName: json['genreName'] as String?,
      coverArtUrl: json['coverArtUrl'] as String?,
      durationSeconds: parseInt(json['durationSeconds']),
      unlockCostCoins: parseInt(json['unlockCostCoins']),
      isFree: json['isFree'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }
}
