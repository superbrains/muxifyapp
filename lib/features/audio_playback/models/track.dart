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

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.albumName,
    this.artworkUrl,
    this.audioUrl,
    this.isUnlocked = true,
  });

  Track copyWith({
    String? audioUrl,
    String? artworkUrl,
    bool? isUnlocked,
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
