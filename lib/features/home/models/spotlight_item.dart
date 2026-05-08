import 'package:muxify/features/home/data/feed_dtos.dart';

class SpotlightItem {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String playCount;
  final String? imageUrl;
  final bool isUnlocked;
  final bool isPlayable;

  SpotlightItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.playCount,
    this.artistId,
    this.imageUrl,
    this.isUnlocked = false,
    this.isPlayable = false,
  });

  factory SpotlightItem.fromSpotlightDto(SpotlightDto dto) {
    final type = dto.type.toLowerCase();
    return SpotlightItem(
      id: dto.contentId ?? dto.id,
      title: dto.title,
      artist: dto.subtitle ?? '',
      playCount: '',
      imageUrl: dto.imageUrl.isEmpty ? null : dto.imageUrl,
      isUnlocked: true,
      isPlayable: type == 'track' || type == 'video',
    );
  }

  factory SpotlightItem.fromMostGiftedDto(MostGiftedTrackDto dto) {
    return SpotlightItem(
      id: dto.id,
      title: dto.title,
      artist: dto.artistName,
      artistId: dto.artistId,
      playCount: _formatGifts(dto.totalGiftsReceived),
      imageUrl: dto.coverArtUrl,
      isUnlocked: true,
      isPlayable: true,
    );
  }

  factory SpotlightItem.fromTopGiverDto(TopGiverDto dto) {
    final name = (dto.displayName ?? dto.username ?? 'Fan').trim();
    final medal = dto.medal.trim();
    return SpotlightItem(
      id: dto.id,
      title: name.isEmpty ? 'Fan' : name,
      artist: medal.isEmpty ? 'Top Giver' : medal,
      playCount: _formatCoins(dto.totalGiftValue),
      imageUrl: dto.avatarUrl,
      isUnlocked: true,
      isPlayable: false,
    );
  }

  static String _formatGifts(int count) {
    if (count <= 0) return '';
    final formatted = _formatThousands(count);
    return '$formatted gifts';
  }

  static String _formatCoins(int value) {
    if (value <= 0) return '';
    return '${_formatThousands(value)} coins sent';
  }

  static String _formatThousands(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}
