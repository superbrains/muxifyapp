/// Mirrors backend `TrackLikeStatusDto`.
class TrackLikeStatus {
  final String trackId;
  final bool liked;
  final int likeCount;

  const TrackLikeStatus({
    required this.trackId,
    required this.liked,
    required this.likeCount,
  });

  factory TrackLikeStatus.fromJson(Map<String, dynamic> json) {
    final rawCount = json['likeCount'];
    return TrackLikeStatus(
      trackId: (json['trackId'] ?? '').toString(),
      liked: json['liked'] == true,
      likeCount: rawCount is int
          ? rawCount
          : int.tryParse((rawCount ?? '0').toString()) ?? 0,
    );
  }
}
