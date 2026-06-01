// Model for album/playlist items
class AlbumItem {
  final String id;
  final String title;
  final String artist;
  final String giftCount;
  final String? albumArtUrl;

  /// Real backend play count, shown on the artist "Most Played" card.
  final int playCount;

  AlbumItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.giftCount,
    this.albumArtUrl,
    this.playCount = 0,
  });

  // Factory constructor for creating from JSON (backend data)
  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      giftCount: json['giftCount'] as String,
      albumArtUrl: json['albumArtUrl'] as String?,
      playCount: (json['playCount'] is num)
          ? (json['playCount'] as num).toInt()
          : 0,
    );
  }
}
