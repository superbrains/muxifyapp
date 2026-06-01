import 'package:muxify/features/home/data/feed_dtos.dart';

/// Discriminates what a spotlight card represents so the tap handler can route
/// to the right destination (player vs artist profile vs fan profile) without
/// inferring intent from the active tab id.
enum SpotlightKind { curated, track, video, artist, giver }

class SpotlightItem {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String playCount;
  final String? imageUrl;
  final bool isUnlocked;
  final bool isPlayable;

  /// What this card represents (drives navigation + visual treatment).
  final SpotlightKind kind;

  /// 1-based leaderboard position, or null for non-ranked (curated) items.
  /// Used to render the gold/silver/bronze rank badge on the top three.
  final int? rank;

  /// Medal tier label for top-giver cards (e.g. "gold", "diamond"); null otherwise.
  final String? medal;

  SpotlightItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.playCount,
    this.artistId,
    this.imageUrl,
    this.isUnlocked = false,
    this.isPlayable = false,
    this.kind = SpotlightKind.curated,
    this.rank,
    this.medal,
  });

  factory SpotlightItem.fromSpotlightDto(SpotlightDto dto) {
    final type = dto.type.toLowerCase();
    final playable = type == 'track' || type == 'video';
    return SpotlightItem(
      id: dto.contentId ?? dto.id,
      title: dto.title,
      artist: dto.subtitle ?? '',
      playCount: '',
      imageUrl: dto.imageUrl.isEmpty ? null : dto.imageUrl,
      isUnlocked: true,
      isPlayable: playable,
      kind: type == 'video'
          ? SpotlightKind.video
          : (type == 'track' ? SpotlightKind.track : SpotlightKind.curated),
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
      kind: SpotlightKind.track,
      rank: dto.rank > 0 ? dto.rank : null,
    );
  }

  factory SpotlightItem.fromMostGiftedArtistDto(
    MostGiftedArtistDto dto, {
    bool isVideoCreator = false,
  }) {
    return SpotlightItem(
      id: dto.id,
      title: dto.name.trim().isEmpty ? 'Unknown' : dto.name,
      artist: _artistSubtitle(dto.totalGiftsReceived, dto.followerCount),
      artistId: dto.id,
      playCount: _formatCoins(dto.totalGiftValue),
      imageUrl: dto.avatarUrl,
      isUnlocked: true,
      isPlayable: false,
      kind: SpotlightKind.artist,
      rank: dto.rank > 0 ? dto.rank : null,
    );
  }

  factory SpotlightItem.fromTopGiverDto(TopGiverDto dto) {
    final name = (dto.displayName ?? dto.username ?? 'Fan').trim();
    final medal = dto.medal.trim();
    return SpotlightItem(
      id: dto.id,
      title: name.isEmpty ? 'Fan' : name,
      artist: medal.isEmpty ? 'Top Giver' : _titleCase(medal),
      playCount: _formatCoins(dto.totalGiftValue),
      imageUrl: dto.avatarUrl,
      isUnlocked: true,
      isPlayable: false,
      kind: SpotlightKind.giver,
      rank: dto.rank > 0 ? dto.rank : null,
      medal: medal.isEmpty ? null : medal.toLowerCase(),
    );
  }

  static String _artistSubtitle(int gifts, int followers) {
    final parts = <String>[];
    if (gifts > 0) parts.add('${_formatThousands(gifts)} gifts');
    if (followers > 0) parts.add('${_compact(followers)} followers');
    return parts.join(' • ');
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  static String _formatGifts(int count) {
    if (count <= 0) return '';
    return '${_formatThousands(count)} gifts';
  }

  static String _formatCoins(int value) {
    if (value <= 0) return '';
    return '${_compact(value)} coins';
  }

  /// Compacts large numbers (≥10,000) to "12.3k" / "1.2M"; smaller values keep
  /// thousands separators so exact small totals stay readable.
  static String _compact(int value) {
    if (value < 10000) return _formatThousands(value);
    if (value < 1000000) {
      final k = value / 1000.0;
      return '${_trim(k)}k';
    }
    final m = value / 1000000.0;
    return '${_trim(m)}M';
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
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
