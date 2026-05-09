import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/features/my_music/models/playable_track.dart';
import 'package:muxify/features/my_music/models/unlocked_track.dart';

/// Page result for the unlocked-content endpoint.
class UnlockedContentPage {
  final List<UnlockedTrack> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const UnlockedContentPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

class PlayableTrackPage {
  final List<PlayableTrack> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const PlayableTrackPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

/// Thin client over the two backend endpoints that drive the My Music feature:
///  - `GET /api/v1/content/unlocked` — every track + video the user owns.
///  - `GET /api/v1/content/playable-tracks` — free + unlocked tracks for the
///    local-playlist track picker.
class MyMusicApi {
  MyMusicApi({ApiRequester? requester}) : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  static const String _unlockedPath = '${ApiConstants.apiV1Prefix}/content/unlocked';
  static const String _playablePath =
      '${ApiConstants.apiV1Prefix}/content/playable-tracks';

  Future<UnlockedContentPage> getUnlocked({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _requester.getJson(
      _unlockedPath,
      (json) => json,
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
      authenticate: true,
    );

    final rawItems = response['items'];
    final parsed = <UnlockedTrack>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        final map = item is Map<String, dynamic>
            ? item
            : (item is Map ? Map<String, dynamic>.from(item) : null);
        if (map == null) continue;
        // Skip videos — Library is tracks-only.
        if ((map['type'] ?? '').toString() != 'track') continue;
        parsed.add(UnlockedTrack.fromJson(map));
      }
    }

    return UnlockedContentPage(
      items: parsed,
      totalCount: _asInt(response['totalCount']),
      page: _asInt(response['page'], fallback: page),
      pageSize: _asInt(response['pageSize'], fallback: pageSize),
      totalPages: _asInt(response['totalPages']),
    );
  }

  /// Fetches every page of unlocked tracks. Useful for the Library, where the
  /// user expects to see the whole list and grouping happens client-side.
  /// Capped at [maxItems] to avoid runaway pagination.
  Future<List<UnlockedTrack>> getAllUnlocked({
    int pageSize = 100,
    int maxItems = 1000,
  }) async {
    final all = <UnlockedTrack>[];
    var page = 1;
    while (all.length < maxItems) {
      final result = await getUnlocked(page: page, pageSize: pageSize);
      all.addAll(result.items);
      if (result.items.isEmpty || page >= result.totalPages) break;
      page += 1;
    }
    return all;
  }

  Future<PlayableTrackPage> getPlayableTracks({
    String? search,
    String? genreId,
    String? artistId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
    };
    final s = search?.trim();
    if (s != null && s.isNotEmpty) query['search'] = s;
    if (genreId != null && genreId.trim().isNotEmpty) query['genreId'] = genreId.trim();
    if (artistId != null && artistId.trim().isNotEmpty) query['artistId'] = artistId.trim();

    final response = await _requester.getJson(
      _playablePath,
      (json) => json,
      queryParameters: query,
      authenticate: true,
    );

    final rawItems = response['items'];
    final parsed = <PlayableTrack>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsed.add(PlayableTrack.fromJson(item));
        } else if (item is Map) {
          parsed.add(PlayableTrack.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PlayableTrackPage(
      items: parsed,
      totalCount: _asInt(response['totalCount']),
      page: _asInt(response['page'], fallback: page),
      pageSize: _asInt(response['pageSize'], fallback: pageSize),
      totalPages: _asInt(response['totalPages']),
    );
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}
