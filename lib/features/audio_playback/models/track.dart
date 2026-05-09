import 'package:just_audio_background/just_audio_background.dart';
import 'package:muxify/core/constants/api_constants.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? albumName;
  final String? artworkUrl;
  final String? audioUrl;
  final bool isUnlocked;

  /// Synchronized lyrics in LRC format (with `[mm:ss.xx]` timestamps), null
  /// when unavailable. Populated only when this Track is built from a fully
  /// hydrated detail response — list/queue items typically leave it null.
  final String? lrcContent;

  /// Origin of [lrcContent]: `"Artist"` or `"LrcLib"`. Used by the player UI
  /// to decide whether to show a lyrics-credit footnote.
  final String? lrcSource;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.albumName,
    this.artworkUrl,
    this.audioUrl,
    this.isUnlocked = true,
    this.lrcContent,
    this.lrcSource,
  });

  Track copyWith({
    String? audioUrl,
    String? artworkUrl,
    bool? isUnlocked,
    String? lrcContent,
    String? lrcSource,
  }) {
    return Track(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      albumName: albumName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      lrcContent: lrcContent ?? this.lrcContent,
      lrcSource: lrcSource ?? this.lrcSource,
    );
  }

  MediaItem toMediaItem() {
    final art = (artworkUrl ?? '').trim();
    Uri? artUri;
    if (art.isNotEmpty) {
      final lower = art.toLowerCase();
      final isRemote =
          lower.startsWith('http://') || lower.startsWith('https://');
      final resolved = isRemote ? art : ApiConstants.resolvePublicUrl(art);
      artUri = Uri.tryParse(resolved);
    }
    return MediaItem(
      id: id,
      title: title.isEmpty ? 'Unknown title' : title,
      artist: artist.isEmpty ? 'Unknown artist' : artist,
      album: albumName,
      artUri: artUri,
    );
  }
}
