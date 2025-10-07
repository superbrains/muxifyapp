class FollowedItem {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;

  FollowedItem({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
  });

  factory FollowedItem.fromJson(Map<String, dynamic> json) {
    return FollowedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
