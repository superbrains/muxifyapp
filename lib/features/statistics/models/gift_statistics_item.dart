class GiftStatisticsItem {
  final String id;
  final String title;
  final String artist;
  final String? albumArtUrl;
  final String giftCount;
  final String giftLabel;

  GiftStatisticsItem({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtUrl,
    required this.giftCount,
    this.giftLabel = 'Received gifts',
  });

  factory GiftStatisticsItem.fromJson(Map<String, dynamic> json) {
    return GiftStatisticsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArtUrl: json['albumArtUrl'] as String?,
      giftCount: json['giftCount'] as String,
      giftLabel: json['giftLabel'] as String? ?? 'Received gifts',
    );
  }
}
