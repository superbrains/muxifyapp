/// Lightweight view of a playlist for the "Add to playlist" picker.
/// Mirrors a subset of backend `PlaylistSummaryDto` fields.
class PlaylistSummary {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int trackCount;

  const PlaylistSummary({
    required this.id,
    required this.name,
    required this.trackCount,
    this.description,
    this.coverImageUrl,
  });

  factory PlaylistSummary.fromJson(Map<String, dynamic> json) {
    final rawCount = json['trackCount'];
    return PlaylistSummary(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] as String?)?.trim().isEmpty == true
          ? null
          : json['description'] as String?,
      coverImageUrl: (json['coverImageUrl'] as String?)?.trim().isEmpty == true
          ? null
          : json['coverImageUrl'] as String?,
      trackCount: rawCount is int
          ? rawCount
          : int.tryParse((rawCount ?? '0').toString()) ?? 0,
    );
  }
}

/// Paged response for `GET /api/v1/playlists`.
class PlaylistList {
  final List<PlaylistSummary> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PlaylistList({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory PlaylistList.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <PlaylistSummary>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map) {
          items.add(PlaylistSummary.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
    }
    int asInt(dynamic v) =>
        v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;
    return PlaylistList(
      items: items,
      totalCount: asInt(json['totalCount']),
      page: asInt(json['page']),
      pageSize: asInt(json['pageSize']),
    );
  }
}
