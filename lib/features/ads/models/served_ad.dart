/// An ad the consumer app should display, plus the single-use token to send back
/// on the impression / click events. Returned by `GET /api/v1/ads/serve` (the
/// endpoint returns 204 when no eligible ad exists, which the service maps to null).
class ServedAd {
  final String campaignId;

  /// Creative format: photo / video / audio.
  final String format;

  final String name;

  /// Proxied creative URL — the primary media: image (photo), video (video), or
  /// the audio file (audio ad, played as the interstitial).
  final String? creativeUrl;

  /// Proxied cover image URL — the visual to show (esp. for an audio ad, where
  /// [creativeUrl] is the audio to play). Null for photo ads (the creative IS the image).
  final String? coverImageUrl;

  /// The advertiser's click-through URL.
  final String? clickUrl;

  /// Single-use token to pass to POST /ads/impressions and /ads/clicks.
  final String impressionToken;

  final String surface;

  const ServedAd({
    required this.campaignId,
    required this.format,
    required this.name,
    required this.creativeUrl,
    required this.coverImageUrl,
    required this.clickUrl,
    required this.impressionToken,
    required this.surface,
  });

  factory ServedAd.fromJson(Map<String, dynamic> json) {
    return ServedAd(
      campaignId: (json['campaignId'] ?? '').toString(),
      format: (json['format'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      creativeUrl: json['creativeUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      clickUrl: json['clickUrl'] as String?,
      impressionToken: (json['impressionToken'] ?? '').toString(),
      surface: (json['surface'] ?? '').toString(),
    );
  }

  bool get isValid => campaignId.isNotEmpty && impressionToken.isNotEmpty;

  /// The image to display: the cover when present, else the creative for photo ads.
  String? get displayImageUrl {
    if (coverImageUrl?.isNotEmpty ?? false) return coverImageUrl;
    if (format == 'photo' && (creativeUrl?.isNotEmpty ?? false)) return creativeUrl;
    return null;
  }

  /// The audio to play for an audio interstitial (null for non-audio ads).
  String? get audioUrl =>
      format == 'audio' && (creativeUrl?.isNotEmpty ?? false) ? creativeUrl : null;
}
