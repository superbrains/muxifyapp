class NowPlayingItem {
  final String id;
  final String title;
  final String artist;
  final String? albumArtUrl;
  final bool isPlaying;
  final bool isUnlocked;

  NowPlayingItem({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtUrl,
    this.isPlaying = false,
    this.isUnlocked = false,
  });

  factory NowPlayingItem.fromJson(Map<String, dynamic> json) {
    return NowPlayingItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArtUrl: json['albumArtUrl'] as String?,
      isPlaying: json['isPlaying'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  NowPlayingItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArtUrl,
    bool? isPlaying,
    bool? isUnlocked,
  }) {
    return NowPlayingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
