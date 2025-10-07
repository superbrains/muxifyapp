// Model for trending artists
class TrendingArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isVerified;

  TrendingArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isVerified = false,
  });

  // Factory constructor for creating from JSON (backend data)
  factory TrendingArtist.fromJson(Map<String, dynamic> json) {
    return TrendingArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
