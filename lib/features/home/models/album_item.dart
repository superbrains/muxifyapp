// Model for album/playlist items
class AlbumItem {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String? description;

  AlbumItem({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.description,
  });

  // Factory constructor for creating from JSON (backend data)
  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}
