// Model for recently played items
class RecentlyPlayedItem {
  final String id;
  final String title;
  final String? imageUrl;
  final String? artist;
  final String? artistId;
  final String type; // "track" or "video"

  RecentlyPlayedItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.artist,
    this.artistId,
    this.type = 'track',
  });

  // Factory constructor for creating from JSON (backend data)
  factory RecentlyPlayedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      artist: (json['artist'] ?? json['artistName']) as String?,
      artistId: json['artistId']?.toString(),
      type: (json['type'] as String?)?.toLowerCase() ?? 'track',
    );
  }
}
