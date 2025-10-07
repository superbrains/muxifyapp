class SpotlightItem {
  final String id;
  final String title;
  final String artist;
  final String playCount;
  final String? imageUrl;
  final bool isUnlocked;

  SpotlightItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.playCount,
    this.imageUrl,
    this.isUnlocked = false,
  });

  factory SpotlightItem.fromJson(Map<String, dynamic> json) {
    return SpotlightItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      playCount: json['playCount'] as String,
      imageUrl: json['imageUrl'] as String?,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }
}
