/// DTOs that mirror `Muxify.Modules.Fans.Application.DTOs.*` from the backend.
/// Kept lightweight (no equality / copyWith) — these only travel from the
/// repository to provider mappers, never into widgets directly.
library;

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v);
  }
  return null;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

class FeedTrackDto {
  final String id;
  final String title;
  final String artistName;
  final String? artistId;
  final String? coverArtUrl;
  final int durationSeconds;
  final String? genreName;
  final int playCount;
  final int likeCount;
  final DateTime? releaseDate;
  final DateTime? createdAt;
  final bool isUnlocked;
  final int unlockCostCoins;

  FeedTrackDto({
    required this.id,
    required this.title,
    required this.artistName,
    this.artistId,
    this.coverArtUrl,
    this.durationSeconds = 0,
    this.genreName,
    this.playCount = 0,
    this.likeCount = 0,
    this.releaseDate,
    this.createdAt,
    this.isUnlocked = false,
    this.unlockCostCoins = 0,
  });

  factory FeedTrackDto.fromJson(Map<String, dynamic> json) {
    return FeedTrackDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artistName: (json['artistName'] ?? '').toString(),
      artistId: json['artistId']?.toString(),
      coverArtUrl: json['coverArtUrl'] as String?,
      durationSeconds: _parseInt(json['durationSeconds']),
      genreName: json['genreName'] as String?,
      playCount: _parseInt(json['playCount']),
      likeCount: _parseInt(json['likeCount']),
      releaseDate: _parseDate(json['releaseDate']),
      createdAt: _parseDate(json['createdAt']),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockCostCoins: _parseInt(json['unlockCostCoins']),
    );
  }
}

class FeedPlaylistDto {
  final String id;
  final String name;
  final String? description;
  final String? coverArtUrl;
  final String? ownerId;
  final String ownerName;
  final int trackCount;
  final int playCount;
  final bool isFeatured;

  FeedPlaylistDto({
    required this.id,
    required this.name,
    this.description,
    this.coverArtUrl,
    this.ownerId,
    this.ownerName = '',
    this.trackCount = 0,
    this.playCount = 0,
    this.isFeatured = false,
  });

  factory FeedPlaylistDto.fromJson(Map<String, dynamic> json) {
    return FeedPlaylistDto(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      coverArtUrl: json['coverArtUrl'] as String?,
      ownerId: json['ownerId']?.toString(),
      ownerName: (json['ownerName'] ?? '').toString(),
      trackCount: _parseInt(json['trackCount']),
      playCount: _parseInt(json['playCount']),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}

class SpotlightDto {
  final String id;
  final String title;
  final String? subtitle;
  final String type; // "track" | "video" | "playlist" | "external"
  final String? contentId;
  final String? externalUrl;
  final String imageUrl;

  SpotlightDto({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    this.subtitle,
    this.contentId,
    this.externalUrl,
  });

  factory SpotlightDto.fromJson(Map<String, dynamic> json) {
    return SpotlightDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle'] as String?,
      type: (json['type'] ?? 'external').toString(),
      contentId: json['contentId']?.toString(),
      externalUrl: json['externalUrl'] as String?,
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }
}

class MostGiftedTrackDto {
  final String id;
  final String title;
  final String artistName;
  final String? artistId;
  final String? coverArtUrl;
  final int totalGiftsReceived;
  final int totalGiftValue;
  final int rank;

  MostGiftedTrackDto({
    required this.id,
    required this.title,
    required this.artistName,
    this.artistId,
    this.coverArtUrl,
    this.totalGiftsReceived = 0,
    this.totalGiftValue = 0,
    this.rank = 0,
  });

  factory MostGiftedTrackDto.fromJson(Map<String, dynamic> json) {
    return MostGiftedTrackDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artistName: (json['artistName'] ?? '').toString(),
      artistId: json['artistId']?.toString(),
      coverArtUrl: json['coverArtUrl'] as String?,
      totalGiftsReceived: _parseInt(json['totalGiftsReceived']),
      totalGiftValue: _parseInt(json['totalGiftValue']),
      rank: _parseInt(json['rank']),
    );
  }
}

class TopGiverDto {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final int totalGiftValue;
  final int totalGiftCount;
  final String medal;
  final int rank;

  TopGiverDto({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.totalGiftValue = 0,
    this.totalGiftCount = 0,
    this.medal = '',
    this.rank = 0,
  });

  factory TopGiverDto.fromJson(Map<String, dynamic> json) {
    return TopGiverDto(
      id: (json['id'] ?? '').toString(),
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      totalGiftValue: _parseInt(json['totalGiftValue']),
      totalGiftCount: _parseInt(json['totalGiftCount']),
      medal: (json['medal'] ?? '').toString(),
      rank: _parseInt(json['rank']),
    );
  }
}
