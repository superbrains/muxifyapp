// Model for track/song items
class TrackItem {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? imageUrl;
  final String? duration;
  final bool isUnlocked;
  final int unlockCostCoins;

  TrackItem({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.imageUrl,
    this.duration,
    this.isUnlocked = true,
    this.unlockCostCoins = 0,
  });

  // Factory constructor for creating from JSON (backend data)
  factory TrackItem.fromJson(Map<String, dynamic> json) {
    return TrackItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      artistId: json['artistId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      duration: json['duration'] as String?,
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      unlockCostCoins: _parseInt(json['unlockCostCoins']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
