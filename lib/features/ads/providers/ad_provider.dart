import 'package:flutter/foundation.dart';
import 'package:muxify/features/ads/models/served_ad.dart';
import 'package:muxify/features/ads/services/ads_api_service.dart';

/// Drives a single ad slot: fetches an ad for a surface, fires the impression
/// once it's shown, and records the click on tap. Each [AdBanner] owns one
/// instance, so slots are independent and disposed with their widget.
class AdProvider extends ChangeNotifier {
  AdProvider({AdsApiService? service})
      : _service = service ?? AdsApiService();

  final AdsApiService _service;

  ServedAd? _ad;
  bool _loading = false;
  bool _impressionFired = false;
  bool _disposed = false;

  ServedAd? get ad => _ad;
  bool get loading => _loading;

  /// Fetches an ad for [surface]; on success (and once only) fires the impression
  /// since the ad is about to be shown.
  Future<void> load({
    required String surface,
    String? format,
    String? targetContentId,
  }) async {
    _loading = true;
    _safeNotify();

    _ad = await _service.serve(
      surface: surface,
      format: format,
      targetContentId: targetContentId,
    );

    _loading = false;
    _safeNotify();

    final ad = _ad;
    if (ad != null && !_impressionFired) {
      _impressionFired = true;
      // Fire-and-forget — billing happens server-side.
      _service.recordImpression(
        campaignId: ad.campaignId,
        impressionToken: ad.impressionToken,
        surface: surface,
      );
    }
  }

  /// Records the click for the current ad (best-effort).
  Future<void> registerClick() async {
    final ad = _ad;
    if (ad == null) return;
    await _service.recordClick(
      campaignId: ad.campaignId,
      impressionToken: ad.impressionToken,
      surface: ad.surface,
    );
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
