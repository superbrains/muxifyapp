// Model for trending artists (discover `/api/v1/discover/trending/artists` items).
class TrendingArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isVerified;
  final int followerCount;
  final int totalPlays;
  final int giftCoinsReceived;
  final int rank;
  final int rankChange;
  final bool isFollowing;

  TrendingArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isVerified = false,
    this.followerCount = 0,
    this.totalPlays = 0,
    this.giftCoinsReceived = 0,
    this.rank = 0,
    this.rankChange = 0,
    this.isFollowing = false,
  });

  /// Backend discover DTO uses [avatarUrl]; some callers use [imageUrl].
  factory TrendingArtist.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final avatar =
        json['avatarUrl'] as String? ?? json['imageUrl'] as String?;
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return TrendingArtist(
      id: rawId is String ? rawId : rawId?.toString() ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: avatar,
      isVerified: json['isVerified'] as bool? ?? false,
      followerCount: asInt(json['followerCount']),
      totalPlays: asInt(json['totalPlays']),
      giftCoinsReceived: asInt(json['giftCoinsReceived']),
      rank: asInt(json['rank']),
      rankChange: asInt(json['rankChange']),
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }
}
