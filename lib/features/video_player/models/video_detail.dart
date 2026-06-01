import 'package:muxify/core/constants/api_constants.dart';

/// Mirrors backend `VideoDetailDto` (GET /api/v1/content/videos/{id}). This is
/// the authoritative source for the video screen — unlock state, pricing, the
/// real artist avatar, counts, description and the current user's like state.
class VideoDetail {
  final String id;
  final String title;
  final String? description;
  final String artistId;
  final String artistName;

  /// Proxied avatar path (e.g. `/api/v1/media/cover/avatars/...`). Render with
  /// [AuthNetworkImage], which attaches the JWT for Muxify-hosted media.
  final String? artistAvatarUrl;
  final String videoType;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String? resolution;
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final bool isPublished;
  final DateTime? createdAt;
  final bool isUnlocked;
  final int unlockCostCoins;
  final bool isLiked;
  final bool isArtistFollowed;

  const VideoDetail({
    required this.id,
    required this.title,
    this.description,
    required this.artistId,
    required this.artistName,
    this.artistAvatarUrl,
    this.videoType = 'musicvideo',
    this.thumbnailUrl,
    this.durationSeconds = 0,
    this.resolution,
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.isPublished = true,
    this.createdAt,
    this.isUnlocked = false,
    this.unlockCostCoins = 0,
    this.isLiked = false,
    this.isArtistFollowed = false,
  });

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) =>
        v is int ? v : int.tryParse((v ?? '0').toString()) ?? 0;

    final rawThumb = (json['thumbnailUrl'] as String?)?.trim();
    final rawAvatar = (json['artistAvatarUrl'] as String?)?.trim();

    return VideoDetail(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] as String?)?.trim(),
      artistId: (json['artistId'] ?? '').toString(),
      artistName: (json['artistName'] ?? '').toString(),
      artistAvatarUrl: (rawAvatar == null || rawAvatar.isEmpty)
          ? null
          : ApiConstants.resolvePublicUrl(rawAvatar),
      videoType: (json['videoType'] ?? 'musicvideo').toString(),
      thumbnailUrl: (rawThumb == null || rawThumb.isEmpty)
          ? null
          : ApiConstants.resolvePublicUrl(rawThumb),
      durationSeconds: asInt(json['durationSeconds']),
      resolution: (json['resolution'] as String?)?.trim(),
      viewCount: asInt(json['viewCount']),
      likeCount: asInt(json['likeCount']),
      shareCount: asInt(json['shareCount']),
      isPublished: json['isPublished'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      isUnlocked: json['isUnlocked'] == true,
      unlockCostCoins: asInt(json['unlockCostCoins']),
      isLiked: json['isLiked'] == true,
      isArtistFollowed: json['isArtistFollowed'] == true,
    );
  }

  VideoDetail copyWith({bool? isUnlocked, bool? isLiked, int? likeCount}) {
    return VideoDetail(
      id: id,
      title: title,
      description: description,
      artistId: artistId,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
      videoType: videoType,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
      resolution: resolution,
      viewCount: viewCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount,
      isPublished: isPublished,
      createdAt: createdAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCostCoins: unlockCostCoins,
      isLiked: isLiked ?? this.isLiked,
      isArtistFollowed: isArtistFollowed,
    );
  }
}

/// Mirrors backend `VideoLikeStatusDto` (POST /api/v1/content/videos/{id}/like).
class VideoLikeStatus {
  final String videoId;
  final bool liked;
  final int likeCount;

  const VideoLikeStatus({
    required this.videoId,
    required this.liked,
    required this.likeCount,
  });

  factory VideoLikeStatus.fromJson(Map<String, dynamic> json) {
    final rawCount = json['likeCount'];
    return VideoLikeStatus(
      videoId: (json['videoId'] ?? '').toString(),
      liked: json['liked'] == true,
      likeCount: rawCount is int
          ? rawCount
          : int.tryParse((rawCount ?? '0').toString()) ?? 0,
    );
  }
}
