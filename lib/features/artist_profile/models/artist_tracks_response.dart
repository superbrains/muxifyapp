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
    return ArtistTracksResponse(
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ArtistTrackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
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
      id: json['id'] as String,
      title: json['title'] as String,
      coverArtUrl: json['coverArtUrl'] as String,
      albumId: json['albumId'] as String,
      albumName: json['albumName'] as String,
      genreName: json['genreName'] as String,
      durationSeconds: json['durationSeconds'] as int,
      playCount: json['playCount'] as int,
      likeCount: json['likeCount'] as int,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isUnlocked: json['isUnlocked'] as bool,
      unlockCostCoins: json['unlockCostCoins'] as int,
    );
  }
}
