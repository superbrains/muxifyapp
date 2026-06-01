import 'package:muxify/features/home/data/feed_dtos.dart';

/// Discriminates what a spotlight card represents so the tap handler can route
/// to the right destination (player vs artist profile vs fan profile) without
/// inferring intent from the active tab id, and so the UI can pick the right
/// presentation (curated banner vs compact leaderboard row).
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
  final int? rank;

  /// Medal tier label for top-giver cards (e.g. "gold", "diamond"); null when
  /// the giver has no medal yet.
  final String? medal;

  /// Hero metric shown on the trailing edge of a leaderboard row — the value
  /// the row is RANKED by (coins). Empty for curated items.
  final String metricPrimary;

  /// Supporting metric under the hero (e.g. "23 gifts"). Empty for curated.
  final String metricSecondary;

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
    this.metricPrimary = '',
    this.metricSecondary = '',
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
      playCount: '',
      imageUrl: dto.coverArtUrl,
      isUnlocked: true,
      isPlayable: true,
      kind: SpotlightKind.track,
      rank: dto.rank > 0 ? dto.rank : null,
      metricPrimary: _compact(dto.totalGiftValue),
      metricSecondary: _giftsLabel(dto.totalGiftsReceived),
    );
  }

  factory SpotlightItem.fromMostGiftedVideoDto(MostGiftedVideoDto dto) {
    return SpotlightItem(
      id: dto.id,
      title: dto.title,
      artist: dto.artistName,
      artistId: dto.artistId,
      playCount: '',
      imageUrl: dto.thumbnailUrl,
      isUnlocked: true,
      isPlayable: true,
      kind: SpotlightKind.video,
      rank: dto.rank > 0 ? dto.rank : null,
      metricPrimary: _compact(dto.totalGiftValue),
      metricSecondary: _giftsLabel(dto.totalGiftsReceived),
    );
  }

  factory SpotlightItem.fromMostGiftedArtistDto(
    MostGiftedArtistDto dto, {
    bool isVideoCreator = false,
  }) {
    return SpotlightItem(
      id: dto.id,
      title: dto.name.trim().isEmpty ? 'Unknown' : dto.name,
      artist: dto.followerCount > 0
          ? '${_compact(dto.followerCount)} followers'
          : '',
      artistId: dto.id,
      playCount: '',
      imageUrl: dto.avatarUrl,
      isUnlocked: true,
      isPlayable: false,
      kind: SpotlightKind.artist,
      rank: dto.rank > 0 ? dto.rank : null,
      metricPrimary: _compact(dto.totalGiftValue),
      metricSecondary: _giftsLabel(dto.totalGiftsReceived),
    );
  }

  factory SpotlightItem.fromTopGiverDto(TopGiverDto dto) {
    final name = (dto.displayName ?? dto.username ?? 'Fan').trim();
    final medal = _normalizeMedal(dto.medal);
    return SpotlightItem(
      id: dto.id,
      title: name.isEmpty ? 'Fan' : name,
      artist: '',
      playCount: '',
      imageUrl: dto.avatarUrl,
      isUnlocked: true,
      isPlayable: false,
      kind: SpotlightKind.giver,
      rank: dto.rank > 0 ? dto.rank : null,
      medal: medal,
      metricPrimary: _compact(dto.totalGiftValue),
      metricSecondary: _giftsLabel(dto.totalGiftCount),
    );
  }

  /// Treats the backend's "none"/empty/"0" medal tiers as "no medal".
  static String? _normalizeMedal(String raw) {
    final m = raw.trim().toLowerCase();
    if (m.isEmpty || m == 'none' || m == '0') return null;
    return m;
  }

  static String _giftsLabel(int count) {
    if (count <= 0) return '';
    return '${_compact(count)} ${count == 1 ? 'gift' : 'gifts'}';
  }

  /// Compacts large numbers (≥10,000) to "12.3k" / "1.2M"; smaller values keep
  /// thousands separators so exact small totals stay readable.
  static String _compact(int value) {
    if (value <= 0) return '0';
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
