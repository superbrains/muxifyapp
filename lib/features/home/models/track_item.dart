// Model for track/song items
class TrackItem {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String? duration;

  TrackItem({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.duration,
  });

  // Factory constructor for creating from JSON (backend data)
  factory TrackItem.fromJson(Map<String, dynamic> json) {
    return TrackItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      imageUrl: json['imageUrl'] as String?,
      duration: json['duration'] as String?,
    );
  }
}
