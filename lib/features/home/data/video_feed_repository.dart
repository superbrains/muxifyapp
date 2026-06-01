import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';

/// Repository for the Home Videos tab feeds.
/// Each method maps to one `/api/v1/feed/videos/...` endpoint and returns the
/// parsed list of items. Errors propagate as `ApiRequestException` so callers
/// can decide whether to silence (empty section) or surface them.
class VideoFeedRepository {
  VideoFeedRepository({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<List<FeedVideoDto>> getTrendingVideos({
    String? videoType,
    String? period,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (videoType != null && videoType.trim().isNotEmpty) {
      query['videoType'] = videoType;
    }
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedTrendingVideosPath,
      FeedVideoDto.fromJson,
      query,
    );
  }

  Future<List<FeedVideoDto>> getHotReleaseVideos({
    String? videoType,
    String? category,
    int days = 14,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'days': days.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (videoType != null && videoType.trim().isNotEmpty) {
      query['videoType'] = videoType;
    }
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedHotReleaseVideosPath,
      FeedVideoDto.fromJson,
      query,
    );
  }

  Future<List<FeedVideoDto>> getTopChartVideos({
    String? videoType,
    String? period,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (videoType != null && videoType.trim().isNotEmpty) {
      query['videoType'] = videoType;
    }
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedTopChartVideosPath,
      FeedVideoDto.fromJson,
      query,
    );
  }

  Future<List<FeedVideoDto>> getNewReleaseVideos({
    String? videoType,
    String? category,
    int days = 30,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'days': days.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (videoType != null && videoType.trim().isNotEmpty) {
      query['videoType'] = videoType;
    }
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedNewReleaseVideosPath,
      FeedVideoDto.fromJson,
      query,
    );
  }

  Future<List<FeedVideoDto>> getVideosFromFollowing({
    String? videoType,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (videoType != null && videoType.trim().isNotEmpty) {
      query['videoType'] = videoType;
    }
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedVideosFromFollowingPath,
      FeedVideoDto.fromJson,
      query,
    );
  }

  Future<List<SpotlightDto>> getVideoSpotlight({int take = 5}) async {
    // /feed/videos/spotlight returns IEnumerable<SpotlightDto> directly (not paginated).
    final response = await _requester.getJsonList(
      ApiConstants.feedVideoSpotlightPath,
      SpotlightDto.fromJson,
      queryParameters: {'take': take.toString()},
      authenticate: true,
    );
    return response;
  }

  Future<List<MostGiftedVideoDto>> getMostGiftedVideos({
    String? period,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedMostGiftedVideosPath,
      MostGiftedVideoDto.fromJson,
      query,
    );
  }

  Future<List<MostGiftedArtistDto>> getMostGiftedCreators({
    String? period,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (category != null && category.trim().isNotEmpty) query['category'] = category;
    return _list(
      ApiConstants.feedMostGiftedCreatorsPath,
      MostGiftedArtistDto.fromJson,
      query,
    );
  }

  /// Top givers scoped to the video vertical (fans who gifted video content).
  Future<List<TopGiverDto>> getVideoTopGivers({
    String? period,
    int page = 1,
    int pageSize = 10,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    return _list(
      ApiConstants.feedVideoTopGiversPath,
      TopGiverDto.fromJson,
      query,
    );
  }

  /// Helper for the standard `FeedListDto<T>` envelope: `{ items, totalCount, page, pageSize }`.
  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> query,
  ) async {
    final response = await _requester.getJson(
      path,
      (json) => json,
      queryParameters: query,
      authenticate: true,
    );

    final rawItems = response['items'];
    if (rawItems is! List) return const [];

    final out = <T>[];
    for (final item in rawItems) {
      if (item is Map<String, dynamic>) {
        out.add(fromJson(item));
      } else if (item is Map) {
        out.add(fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }
}
