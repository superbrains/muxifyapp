class ArtistTracksResponse {
  final String artistId;
  final String artistName;
  final List<ArtistTrackItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  ArtistTracksResponse({
    required this.artistId,
    required this.artistName,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ArtistTracksResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final parsedItems = itemsJson is List
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(ArtistTrackItem.fromJson)
              .toList()
        : const <ArtistTrackItem>[];

    return ArtistTracksResponse(
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

class ArtistTrackItem {
  final String id;
  final String title;
  final String coverArtUrl;
  final String albumId;
  final String albumName;
  final String genreName;
  final int durationSeconds;
  final int playCount;
  final int likeCount;
  final DateTime releaseDate;
  final DateTime createdAt;
  final bool isUnlocked;
  final int unlockCostCoins;

  ArtistTrackItem({
    required this.id,
    required this.title,
    required this.coverArtUrl,
    required this.albumId,
    required this.albumName,
    required this.genreName,
    required this.durationSeconds,
    required this.playCount,
    required this.likeCount,
    required this.releaseDate,
    required this.createdAt,
    required this.isUnlocked,
    required this.unlockCostCoins,
  });

  factory ArtistTrackItem.fromJson(Map<String, dynamic> json) {
    return ArtistTrackItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled',
      coverArtUrl: (json['coverArtUrl'] as String?) ?? '',
      albumId: (json['albumId'] as String?) ?? '',
      albumName: (json['albumName'] as String?) ?? '',
      genreName: (json['genreName'] as String?) ?? '',
      durationSeconds: _asInt(json['durationSeconds']),
      playCount: _asInt(json['playCount']),
      likeCount: _asInt(json['likeCount']),
      releaseDate: _asDateTime(json['releaseDate']),
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
