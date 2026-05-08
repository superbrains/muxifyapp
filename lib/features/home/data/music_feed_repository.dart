import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';

/// Repository for the Home Music tab feeds.
/// Each method maps to one `/api/v1/feed/...` endpoint and returns the parsed
/// list of items. Errors propagate as `ApiRequestException` so callers can
/// decide whether to silence (empty section) or surface them.
class MusicFeedRepository {
  MusicFeedRepository({ApiRequester? requester})
      : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<List<FeedTrackDto>> getTrendingTracks({
    String? period,
    String? genre,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (genre != null && genre.trim().isNotEmpty) query['genre'] = genre;
    return _list(
      ApiConstants.feedTrendingTracksPath,
      FeedTrackDto.fromJson,
      query,
    );
  }

  Future<List<FeedTrackDto>> getHotReleases({
    String? genre,
    int days = 14,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'days': days.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (genre != null && genre.trim().isNotEmpty) query['genre'] = genre;
    return _list(
      ApiConstants.feedHotReleasesPath,
      FeedTrackDto.fromJson,
      query,
    );
  }

  Future<List<FeedTrackDto>> getTopCharts({
    String? period,
    String? genre,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (period != null && period.trim().isNotEmpty) query['period'] = period;
    if (genre != null && genre.trim().isNotEmpty) query['genre'] = genre;
    return _list(
      ApiConstants.feedTopChartsPath,
      FeedTrackDto.fromJson,
      query,
    );
  }

  Future<List<FeedTrackDto>> getNewReleases({
    String? genre,
    int days = 30,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'days': days.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (genre != null && genre.trim().isNotEmpty) query['genre'] = genre;
    return _list(
      ApiConstants.feedNewReleasesPath,
      FeedTrackDto.fromJson,
      query,
    );
  }

  Future<List<FeedTrackDto>> getFromFollowing({
    int page = 1,
    int pageSize = 20,
  }) {
    return _list(
      ApiConstants.feedFromFollowingPath,
      FeedTrackDto.fromJson,
      {'page': page.toString(), 'pageSize': pageSize.toString()},
    );
  }

  Future<List<FeedPlaylistDto>> getFeaturedPlaylists({
    int page = 1,
    int pageSize = 10,
  }) {
    return _list(
      ApiConstants.feedFeaturedPlaylistsPath,
      FeedPlaylistDto.fromJson,
      {'page': page.toString(), 'pageSize': pageSize.toString()},
    );
  }

  Future<List<SpotlightDto>> getSpotlight({int take = 5}) async {
    // /feed/spotlight returns IEnumerable<SpotlightDto> directly (not paginated).
    final response = await _requester.getJsonList(
      ApiConstants.feedSpotlightPath,
      SpotlightDto.fromJson,
      queryParameters: {'take': take.toString()},
      authenticate: true,
    );
    return response;
  }

  Future<List<MostGiftedTrackDto>> getMostGifted({
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
      ApiConstants.feedMostGiftedPath,
      MostGiftedTrackDto.fromJson,
      query,
    );
  }

  Future<List<TopGiverDto>> getTopGivers({
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
      ApiConstants.feedTopGiversPath,
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
