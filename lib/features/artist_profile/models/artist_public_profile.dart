class ArtistPublicProfile {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? country;
  final String? state;
  final String? website;
  final bool isVerified;
  final DateTime? joinedAt;

  final String? instagram;
  final String? twitter;
  final String? tikTok;
  final String? youTube;
  final String? spotify;
  final String? facebook;

  final int followerCount;
  final int totalPlays;
  final int trackCount;
  final int albumCount;
  final int videoCount;

  final bool isFollowing;
  final bool notificationsEnabled;

  ArtistPublicProfile({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.country,
    this.state,
    this.website,
    this.isVerified = false,
    this.joinedAt,
    this.instagram,
    this.twitter,
    this.tikTok,
    this.youTube,
    this.spotify,
    this.facebook,
    this.followerCount = 0,
    this.totalPlays = 0,
    this.trackCount = 0,
    this.albumCount = 0,
    this.videoCount = 0,
    this.isFollowing = false,
    this.notificationsEnabled = false,
  });

  factory ArtistPublicProfile.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return ArtistPublicProfile(
      id: rawId is String ? rawId : (rawId?.toString() ?? ''),
      name: (json['name'] as String?) ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      website: json['website'] as String?,
      isVerified: (json['isVerified'] as bool?) ?? false,
      joinedAt: _asDateTime(json['joinedAt']),
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      tikTok: json['tikTok'] as String?,
      youTube: json['youTube'] as String?,
      spotify: json['spotify'] as String?,
      facebook: json['facebook'] as String?,
      followerCount: _asInt(json['followerCount']),
      totalPlays: _asInt(json['totalPlays']),
      trackCount: _asInt(json['trackCount']),
      albumCount: _asInt(json['albumCount']),
      videoCount: _asInt(json['videoCount']),
      isFollowing: (json['isFollowing'] as bool?) ?? false,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? false,
    );
  }

  ArtistPublicProfile copyWith({
    int? followerCount,
    bool? isFollowing,
    bool? notificationsEnabled,
  }) {
    return ArtistPublicProfile(
      id: id,
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      country: country,
      state: state,
      website: website,
      isVerified: isVerified,
      joinedAt: joinedAt,
      instagram: instagram,
      twitter: twitter,
      tikTok: tikTok,
      youTube: youTube,
      spotify: spotify,
      facebook: facebook,
      followerCount: followerCount ?? this.followerCount,
      totalPlays: totalPlays,
      trackCount: trackCount,
      albumCount: albumCount,
      videoCount: videoCount,
      isFollowing: isFollowing ?? this.isFollowing,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
