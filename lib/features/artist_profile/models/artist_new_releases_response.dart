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
    return ArtistNewReleasesResponse(
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ArtistNewReleaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
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
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      trackCount: json['trackCount'] as int,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
