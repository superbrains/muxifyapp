// Model for recently played items
class RecentlyPlayedItem {
  final String id;
  final String title;
  final String? imageUrl;
  final String? artist;

  RecentlyPlayedItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.artist,
  });

  // Factory constructor for creating from JSON (backend data)
  factory RecentlyPlayedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      artist: json['artist'] as String?,
    );
  }
}
