// Data models for the Fan Profile feature. All `fromJson` factories are
// defensive — missing or null fields fall back to safe defaults so the UI can
// render partial data while the rest streams in.

class UserBadge {
  const UserBadge({
    required this.id,
    required this.badgeId,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
    required this.isRare,
    required this.earnedAt,
    this.context,
    this.artistId,
    this.artistName,
    required this.isDisplayed,
  });

  final String id;
  final String badgeId;
  final String type;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int points;
  final bool isRare;
  final DateTime earnedAt;
  final String? context;
  final String? artistId;
  final String? artistName;
  final bool isDisplayed;

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
        id: json['id']?.toString() ?? '',
        badgeId: json['badgeId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
        points: (json['points'] as num?)?.toInt() ?? 0,
        isRare: json['isRare'] == true,
        earnedAt: _parseDate(json['earnedAt']),
        context: json['context']?.toString(),
        artistId: json['artistId']?.toString(),
        artistName: json['artistName']?.toString(),
        isDisplayed: json['isDisplayed'] == true,
      );
}

class UserMedal {
  const UserMedal({
    required this.id,
    required this.medalId,
    required this.tier,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.earnedAt,
    required this.coinsAtEarning,
    this.artistId,
    this.artistName,
  });

  final String id;
  final String medalId;
  final String tier;
  final String name;
  final String description;
  final String icon;
  final String color;
  final DateTime earnedAt;
  final int coinsAtEarning;
  final String? artistId;
  final String? artistName;

  factory UserMedal.fromJson(Map<String, dynamic> json) => UserMedal(
        id: json['id']?.toString() ?? '',
        medalId: json['medalId']?.toString() ?? '',
        tier: json['tier']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        icon: json['icon']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
        earnedAt: _parseDate(json['earnedAt']),
        coinsAtEarning: (json['coinsAtEarning'] as num?)?.toInt() ?? 0,
        artistId: json['artistId']?.toString(),
        artistName: json['artistName']?.toString(),
      );
}

class FanPublicProfile {
  const FanPublicProfile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.isVerified,
    this.bio,
    required this.joinedAt,
    this.currentMedal,
    this.medalIcon,
    this.medalColor,
    required this.badgeCount,
    required this.totalPoints,
    required this.currentStreak,
    required this.totalGiftValue,
    required this.artistsSupportedCount,
    required this.followingCount,
    this.leaderboardRank,
    required this.featuredBadges,
    required this.medals,
  });

  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerified;
  final String? bio;
  final DateTime joinedAt;
  final String? currentMedal;
  final String? medalIcon;
  final String? medalColor;
  final int badgeCount;
  final int totalPoints;
  final int currentStreak;
  final int totalGiftValue;
  final int artistsSupportedCount;
  final int followingCount;
  final int? leaderboardRank;
  final List<UserBadge> featuredBadges;
  final List<UserMedal> medals;

  factory FanPublicProfile.fromJson(Map<String, dynamic> json) =>
      FanPublicProfile(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString(),
        displayName: json['displayName']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        isVerified: json['isVerified'] == true,
        bio: json['bio']?.toString(),
        joinedAt: _parseDate(json['joinedAt']),
        currentMedal: json['currentMedal']?.toString(),
        medalIcon: json['medalIcon']?.toString(),
        medalColor: json['medalColor']?.toString(),
        badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
        totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        totalGiftValue: (json['totalGiftValue'] as num?)?.toInt() ?? 0,
        artistsSupportedCount:
            (json['artistsSupportedCount'] as num?)?.toInt() ?? 0,
        followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
        leaderboardRank: (json['leaderboardRank'] as num?)?.toInt(),
        featuredBadges: _list(json['featuredBadges'])
            .map((e) => UserBadge.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        medals: _list(json['medals'])
            .map((e) => UserMedal.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class SupportedArtist {
  const SupportedArtist({
    required this.artistId,
    this.artistName,
    this.avatarUrl,
    required this.totalGiftValue,
    required this.giftCount,
    required this.firstGiftAt,
    required this.lastGiftAt,
    required this.isFollowing,
  });

  final String artistId;
  final String? artistName;
  final String? avatarUrl;
  final int totalGiftValue;
  final int giftCount;
  final DateTime firstGiftAt;
  final DateTime lastGiftAt;
  final bool isFollowing;

  factory SupportedArtist.fromJson(Map<String, dynamic> json) => SupportedArtist(
        artistId: json['artistId']?.toString() ?? '',
        artistName: json['artistName']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        totalGiftValue: (json['totalGiftValue'] as num?)?.toInt() ?? 0,
        giftCount: (json['giftCount'] as num?)?.toInt() ?? 0,
        firstGiftAt: _parseDate(json['firstGiftAt']),
        lastGiftAt: _parseDate(json['lastGiftAt']),
        isFollowing: json['isFollowing'] == true,
      );
}

class SupportedArtistsList {
  const SupportedArtistsList({
    required this.artists,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<SupportedArtist> artists;
  final int totalCount;
  final int page;
  final int pageSize;

  factory SupportedArtistsList.fromJson(Map<String, dynamic> json) =>
      SupportedArtistsList(
        artists: _list(json['artists'])
            .map((e) => SupportedArtist.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      );
}

class FollowedArtist {
  const FollowedArtist({
    required this.artistId,
    this.artistName,
    this.avatarUrl,
    required this.followedAt,
    required this.notificationsEnabled,
  });

  final String artistId;
  final String? artistName;
  final String? avatarUrl;
  final DateTime followedAt;
  final bool notificationsEnabled;

  factory FollowedArtist.fromJson(Map<String, dynamic> json) => FollowedArtist(
        artistId: json['artistId']?.toString() ?? '',
        artistName: json['artistName']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        followedAt: _parseDate(json['followedAt']),
        notificationsEnabled: json['notificationsEnabled'] == true,
      );
}

class FollowedArtistsList {
  const FollowedArtistsList({
    required this.artists,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<FollowedArtist> artists;
  final int totalCount;
  final int page;
  final int pageSize;

  factory FollowedArtistsList.fromJson(Map<String, dynamic> json) =>
      FollowedArtistsList(
        artists: _list(json['artists'])
            .map((e) => FollowedArtist.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      );
}

class FanActivity {
  const FanActivity({
    required this.id,
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.activityType,
    required this.activityAt,
    required this.points,
    this.artistId,
    this.artistName,
    this.trackId,
    this.trackTitle,
    this.videoId,
    this.videoTitle,
    this.coinValue,
    this.giftType,
    this.badgeName,
    this.medalName,
    this.relatedImageUrl,
  });

  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String activityType;
  final DateTime activityAt;
  final int points;
  final String? artistId;
  final String? artistName;
  final String? trackId;
  final String? trackTitle;
  final String? videoId;
  final String? videoTitle;
  final int? coinValue;
  final String? giftType;
  final String? badgeName;
  final String? medalName;

  /// Proxied image the backend resolved for this activity (track cover, video
  /// thumbnail, or the involved artist's avatar). Null when nothing visual is
  /// associated — the UI then falls back to a type icon.
  final String? relatedImageUrl;

  factory FanActivity.fromJson(Map<String, dynamic> json) => FanActivity(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        username: json['username']?.toString(),
        displayName: json['displayName']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        activityType: json['activityType']?.toString() ?? '',
        activityAt: _parseDate(json['activityAt']),
        points: (json['points'] as num?)?.toInt() ?? 0,
        artistId: json['artistId']?.toString(),
        artistName: json['artistName']?.toString(),
        trackId: json['trackId']?.toString(),
        trackTitle: json['trackTitle']?.toString(),
        videoId: json['videoId']?.toString(),
        videoTitle: json['videoTitle']?.toString(),
        coinValue: (json['coinValue'] as num?)?.toInt(),
        giftType: json['giftType']?.toString(),
        badgeName: json['badgeName']?.toString(),
        medalName: json['medalName']?.toString(),
        relatedImageUrl: json['relatedImageUrl']?.toString(),
      );
}

class FanActivityList {
  const FanActivityList({
    required this.activities,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<FanActivity> activities;
  final int totalCount;
  final int page;
  final int pageSize;

  factory FanActivityList.fromJson(Map<String, dynamic> json) => FanActivityList(
        activities: _list(json['activities'])
            .map((e) => FanActivity.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      );
}

class UserBadgeList {
  const UserBadgeList({
    required this.badges,
    required this.totalCount,
    required this.totalPoints,
  });

  final List<UserBadge> badges;
  final int totalCount;
  final int totalPoints;

  factory UserBadgeList.fromJson(Map<String, dynamic> json) => UserBadgeList(
        badges: _list(json['badges'])
            .map((e) => UserBadge.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      );
}

class UserMedalList {
  const UserMedalList({required this.medals, required this.totalCount});

  final List<UserMedal> medals;
  final int totalCount;

  factory UserMedalList.fromJson(Map<String, dynamic> json) => UserMedalList(
        medals: _list(json['medals'])
            .map((e) => UserMedal.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      );
}

class SendFanGiftResponse {
  const SendFanGiftResponse({
    required this.success,
    required this.giftId,
    required this.coinsSpent,
    required this.newBalance,
    this.message,
  });

  final bool success;
  final String giftId;
  final int coinsSpent;
  final int newBalance;
  final String? message;

  factory SendFanGiftResponse.fromJson(Map<String, dynamic> json) =>
      SendFanGiftResponse(
        success: json['success'] == true,
        giftId: json['giftId']?.toString() ?? '',
        coinsSpent: (json['coinsSpent'] as num?)?.toInt() ?? 0,
        newBalance: (json['newBalance'] as num?)?.toInt() ?? 0,
        message: json['message']?.toString(),
      );
}

DateTime _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  return DateTime.now();
}

List<dynamic> _list(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}
