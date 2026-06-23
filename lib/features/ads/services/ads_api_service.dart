import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/ads/models/served_ad.dart';

/// Calls the consumer ad-delivery endpoints. Serving requires auth (the server
/// reads the viewer's FanProfile for attribution); impressions / clicks are
/// fire-and-forget — a tracking failure must never disrupt playback or the feed.
class AdsApiService {
  AdsApiService({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  /// Requests an ad for [surface]. Returns null when the server has nothing to
  /// serve (HTTP 204) or on any error — the caller renders nothing in that case.
  Future<ServedAd?> serve({
    required String surface,
    String? format,
    String? targetContentId,
  }) async {
    try {
      final ad = await _requester.getJson<ServedAd>(
        ApiConstants.adServePath,
        ServedAd.fromJson,
        queryParameters: {
          'surface': surface,
          if (format != null && format.isNotEmpty) 'format': format,
          if (targetContentId != null && targetContentId.isNotEmpty)
            'targetContentId': targetContentId,
        },
        authenticate: true,
      );
      return ad.isValid ? ad : null;
    } on ApiRequestException catch (e) {
      // 204 = no eligible ad; any other error = render nothing.
      if (e.statusCode == ApiConstants.statusNoContent) return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Records (and bills) an impression. Best-effort.
  Future<void> recordImpression({
    required String campaignId,
    required String impressionToken,
    String? surface,
  }) =>
      _record(ApiConstants.adImpressionsPath, campaignId, impressionToken, surface);

  /// Records (and bills) a click. Best-effort.
  Future<void> recordClick({
    required String campaignId,
    required String impressionToken,
    String? surface,
  }) =>
      _record(ApiConstants.adClicksPath, campaignId, impressionToken, surface);

  Future<void> _record(
    String path,
    String campaignId,
    String impressionToken,
    String? surface,
  ) async {
    try {
      await _requester.postNoContent(
        path,
        {
          'campaignId': campaignId,
          'impressionToken': impressionToken,
          if (surface != null && surface.isNotEmpty) 'surface': surface,
        },
        successStatus: ApiConstants.statusOk,
        authenticate: true,
      );
    } catch (_) {
      // Swallow — tracking must never break the UI.
    }
  }
}
