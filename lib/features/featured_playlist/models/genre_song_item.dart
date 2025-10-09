class GenreSongItem {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  final bool isUnlocked;
  final bool isPlaying;

  const GenreSongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.isUnlocked,
    this.isPlaying = false,
  });

  GenreSongItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArtUrl,
    bool? isUnlocked,
    bool? isPlaying,
  }) {
    return GenreSongItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
