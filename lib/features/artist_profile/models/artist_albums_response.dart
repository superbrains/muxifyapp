class ArtistAlbumsResponse {
  final String artistId;
  final String artistName;
  final List<ArtistAlbumItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  ArtistAlbumsResponse({
    required this.artistId,
    required this.artistName,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ArtistAlbumsResponse.fromJson(Map<String, dynamic> json) {
    return ArtistAlbumsResponse(
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ArtistAlbumItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class ArtistAlbumItem {
  final String id;
  final String title;
  final String coverArtUrl;
  final String releaseType;
  final DateTime releaseDate;
  final int trackCount;
  final int playCount;
  final DateTime createdAt;

  ArtistAlbumItem({
    required this.id,
    required this.title,
    required this.coverArtUrl,
    required this.releaseType,
    required this.releaseDate,
    required this.trackCount,
    required this.playCount,
    required this.createdAt,
  });

  factory ArtistAlbumItem.fromJson(Map<String, dynamic> json) {
    return ArtistAlbumItem(
      id: json['id'] as String,
      title: json['title'] as String,
      coverArtUrl: json['coverArtUrl'] as String,
      releaseType: json['releaseType'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      trackCount: json['trackCount'] as int,
      playCount: json['playCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
