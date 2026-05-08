class ArtistNewReleasesResponse {
  final String artistId;
  final String artistName;
  final List<ArtistNewReleaseItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  ArtistNewReleasesResponse({
    required this.artistId,
    required this.artistName,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ArtistNewReleasesResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final parsedItems = itemsJson is List
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(ArtistNewReleaseItem.fromJson)
              .toList()
        : const <ArtistNewReleaseItem>[];

    return ArtistNewReleasesResponse(
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

class ArtistNewReleaseItem {
  final String id;
  final String type;
  final String title;
  final String imageUrl;
  final DateTime releaseDate;
  final int trackCount;
  final int durationSeconds;

  ArtistNewReleaseItem({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.releaseDate,
    required this.trackCount,
    required this.durationSeconds,
  });

  factory ArtistNewReleaseItem.fromJson(Map<String, dynamic> json) {
    return ArtistNewReleaseItem(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'track',
      title: (json['title'] as String?) ?? 'Untitled',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      releaseDate: _asDateTime(json['releaseDate']),
      trackCount: _asInt(json['trackCount']),
      durationSeconds: _asInt(json['durationSeconds']),
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
