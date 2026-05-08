import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';

class VideoItem {
  final String id;
  final String title;
  final String imageUrl;
  final double progress;
  final String creator;
  final String creatorImageUrl;
  final String? views;
  final String? creatorId;
  final bool isUnlocked;
  final int unlockCostCoins;

  VideoItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.progress = 0.0,
    required this.creator,
    required this.creatorImageUrl,
    this.views,
    this.creatorId,
    this.isUnlocked = true,
    this.unlockCostCoins = 0,
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

  /// Build a UI-facing [VideoItem] from a backend feed DTO.
  factory VideoItem.fromFeedVideo(FeedVideoDto dto) {
    final thumb = (dto.thumbnailUrl ?? '').trim();
    return VideoItem(
      id: dto.id,
      title: dto.title,
      imageUrl: thumb.isEmpty
          ? 'assets/pngs/release_placeholder.png'
          : ApiConstants.resolvePublicUrl(thumb),
      creator: dto.artistName,
      creatorId: dto.artistId,
      creatorImageUrl: '',
      views: _formatCount(dto.viewCount),
      isUnlocked: dto.isUnlocked,
      unlockCostCoins: dto.unlockCostCoins,
    );
  }

  /// Build a UI-facing [VideoItem] from a most-gifted-video DTO.
  factory VideoItem.fromMostGiftedVideo(MostGiftedVideoDto dto) {
    final thumb = (dto.thumbnailUrl ?? '').trim();
    return VideoItem(
      id: dto.id,
      title: dto.title,
      imageUrl: thumb.isEmpty
          ? 'assets/pngs/release_placeholder.png'
          : ApiConstants.resolvePublicUrl(thumb),
      creator: dto.artistName,
      creatorId: dto.artistId,
      creatorImageUrl: '',
      views: _formatCount(dto.totalGiftsReceived),
    );
  }
}

String _formatCount(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  if (n < 1000000000) {
    return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
  }
  return '${(n / 1000000000).toStringAsFixed(1)}B';
}
