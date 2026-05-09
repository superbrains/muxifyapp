/// Mirrors backend `TrackShareDto`. The mobile app feeds `message + shareUrl`
/// into the OS share sheet via `share_plus`.
class TrackShareInfo {
  final String trackId;
  final String title;
  final String artist;
  final String? artworkUrl;
  final String shareUrl;
  final String deeplink;
  final String message;
  final int shareCount;

  const TrackShareInfo({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.shareUrl,
    required this.deeplink,
    required this.message,
    required this.shareCount,
    this.artworkUrl,
  });

  factory TrackShareInfo.fromJson(Map<String, dynamic> json) {
    final rawCount = json['shareCount'];
    return TrackShareInfo(
      trackId: (json['trackId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artist: (json['artist'] ?? '').toString(),
      artworkUrl: (json['artworkUrl'] as String?)?.trim().isEmpty == true
          ? null
          : json['artworkUrl'] as String?,
      shareUrl: (json['shareUrl'] ?? '').toString(),
      deeplink: (json['deeplink'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      shareCount: rawCount is int
          ? rawCount
          : int.tryParse((rawCount ?? '0').toString()) ?? 0,
    );
  }

  /// The body the OS share sheet should display by default. Combines the
  /// human-readable message with the shareable URL.
  String get shareableText {
    final parts = <String>[];
    if (message.trim().isNotEmpty) parts.add(message.trim());
    if (shareUrl.trim().isNotEmpty) parts.add(shareUrl.trim());
    return parts.join('\n');
  }
}
