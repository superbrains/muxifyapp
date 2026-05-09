import 'package:muxify/features/audio_playback/models/track.dart' as audio;
import 'package:muxify/features/my_music/models/playable_track.dart';
import 'package:muxify/features/my_music/models/unlocked_track.dart';

/// Snapshot of the metadata we need to render a track inside a local playlist
/// without re-hitting the network. Streaming URL is resolved on play via the
/// existing `StreamUrlResolver` in `AudioProvider`.
class LocalPlaylistTrack {
  final String trackId;
  final String title;
  final String artist;
  final String? artistId;
  final String? coverArtUrl;
  final int durationSeconds;
  /// True when the track was free at the time it was added — kept as a hint
  /// only; the eligibility guard is re-evaluated on every add against the
  /// current `UnlockedContentProvider` state.
  final bool wasFreeAtAdd;
  final DateTime addedAt;

  const LocalPlaylistTrack({
    required this.trackId,
    required this.title,
    required this.artist,
    this.artistId,
    this.coverArtUrl,
    this.durationSeconds = 0,
    this.wasFreeAtAdd = false,
    required this.addedAt,
  });

  factory LocalPlaylistTrack.fromPlayable(PlayableTrack t, {DateTime? addedAt}) =>
      LocalPlaylistTrack(
        trackId: t.id,
        title: t.title,
        artist: t.artistName,
        artistId: t.artistId,
        coverArtUrl: t.coverArtUrl,
        durationSeconds: t.durationSeconds,
        wasFreeAtAdd: t.isFree,
        addedAt: addedAt ?? DateTime.now().toUtc(),
      );

  factory LocalPlaylistTrack.fromUnlocked(UnlockedTrack t, {DateTime? addedAt}) =>
      LocalPlaylistTrack(
        trackId: t.id,
        title: t.title,
        artist: t.artistName,
        artistId: t.artistId,
        coverArtUrl: t.coverArtUrl,
        durationSeconds: t.durationSeconds,
        wasFreeAtAdd: t.unlockCostCoins == 0,
        addedAt: addedAt ?? DateTime.now().toUtc(),
      );

  audio.Track toPlaybackTrack() => audio.Track(
        id: trackId,
        title: title,
        artist: artist,
        artistId: artistId,
        artworkUrl: coverArtUrl,
        isUnlocked: true,
      );

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'coverArtUrl': coverArtUrl,
        'durationSeconds': durationSeconds,
        'wasFreeAtAdd': wasFreeAtAdd,
        'addedAt': addedAt.toIso8601String(),
      };

  factory LocalPlaylistTrack.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return LocalPlaylistTrack(
      trackId: (json['trackId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artist: (json['artist'] ?? '').toString(),
      artistId: json['artistId']?.toString(),
      coverArtUrl: json['coverArtUrl'] as String?,
      durationSeconds: parseInt(json['durationSeconds']),
      wasFreeAtAdd: json['wasFreeAtAdd'] as bool? ?? false,
      addedAt: DateTime.tryParse((json['addedAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
    );
  }
}
