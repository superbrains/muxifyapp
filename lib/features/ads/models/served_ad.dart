/// An ad the consumer app should display, plus the single-use token to send back
/// on the impression / click events. Returned by `GET /api/v1/ads/serve` (the
/// endpoint returns 204 when no eligible ad exists, which the service maps to null).
class ServedAd {
  final String campaignId;

  /// Creative format: photo / video / audio.
  final String format;

  final String name;

  /// Proxied creative URL (image/video/audio), ready for [AuthNetworkImage].
  final String? creativeUrl;

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
      clickUrl: json['clickUrl'] as String?,
      impressionToken: (json['impressionToken'] ?? '').toString(),
      surface: (json['surface'] ?? '').toString(),
    );
  }

  bool get isValid => campaignId.isNotEmpty && impressionToken.isNotEmpty;
}
