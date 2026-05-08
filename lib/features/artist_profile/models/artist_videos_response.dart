class ArtistVideosResponse {
  final String artistId;
  final String artistName;
  final List<ArtistVideoItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  ArtistVideosResponse({
    required this.artistId,
    required this.artistName,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ArtistVideosResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final parsedItems = itemsJson is List
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(ArtistVideoItem.fromJson)
              .toList()
        : const <ArtistVideoItem>[];

    return ArtistVideosResponse(
      artistId: (json['artistId'] as String?) ?? '',
      artistName: (json['artistName'] as String?) ?? 'Artist',
      items: parsedItems,
      totalCount: _asInt(json['totalCount']),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(
        json['pageSize'],
        fallback: parsedItems.isEmpty ? 0 : parsedItems.length,
      ),
      totalPages: _asInt(json['totalPages'], fallback: 1),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

class ArtistVideoItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoType;
  final int durationSeconds;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isUnlocked;
  final int unlockCostCoins;

  ArtistVideoItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoType,
    required this.durationSeconds,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    required this.isUnlocked,
    required this.unlockCostCoins,
  });

  factory ArtistVideoItem.fromJson(Map<String, dynamic> json) {
    return ArtistVideoItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled',
      thumbnailUrl: (json['thumbnailUrl'] as String?) ?? '',
      videoType: (json['videoType'] as String?) ?? '',
      durationSeconds: _asInt(json['durationSeconds']),
      viewCount: _asInt(json['viewCount']),
      likeCount: _asInt(json['likeCount']),
      createdAt: _asDateTime(json['createdAt']),
      isUnlocked: (json['isUnlocked'] as bool?) ?? false,
      unlockCostCoins: _asInt(json['unlockCostCoins']),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
