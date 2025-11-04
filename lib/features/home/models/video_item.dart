class VideoItem {
  final String id;
  final String title;
  final String imageUrl;
  final double progress;
  final String creator;
  final String creatorImageUrl;
  final String? views;

  VideoItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.progress = 0.0,
    required this.creator,  
    required this.creatorImageUrl,
    this.views,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      creator: json['creator'] as String,
      creatorImageUrl: json['creatorImageUrl'] as String,
      views: json['views'] as String?,
    );
  }
}
