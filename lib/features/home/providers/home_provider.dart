import 'package:flutter/foundation.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  List<RecentlyPlayedItem> _recentlyPlayed = const [];
  bool _isLoadingRecentlyPlayed = false;
  bool _hasLoadedRecentlyPlayed = false;

  List<RecentlyPlayedItem> get recentlyPlayed => _recentlyPlayed;
  bool get isLoadingRecentlyPlayed => _isLoadingRecentlyPlayed;
  bool get hasLoadedRecentlyPlayed => _hasLoadedRecentlyPlayed;

  List<TrendingArtist> _trendingArtists = const [];
  bool _isLoadingTrendingArtists = false;
  bool _hasLoadedTrendingArtists = false;

  List<TrendingArtist> get trendingArtists => _trendingArtists;
  bool get isLoadingTrendingArtists => _isLoadingTrendingArtists;
  bool get hasLoadedTrendingArtists => _hasLoadedTrendingArtists;

  Future<void> loadRecentlyPlayed({bool forceRefresh = false}) async {
    if (_isLoadingRecentlyPlayed) return;
    if (!forceRefresh && _hasLoadedRecentlyPlayed) return;

    _isLoadingRecentlyPlayed = true;
    notifyListeners();

    try {
      final response = await _requester.getJson(
        '/api/v1/feed/recently-played',
        (json) => json,
        queryParameters: const {'pageSize': 5},
        authenticate: true,
      );

      final rawItems = response['items'];
      final parsed = <RecentlyPlayedItem>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map<String, dynamic>) {
            parsed.add(RecentlyPlayedItem.fromJson(item));
          } else if (item is Map) {
            parsed.add(
              RecentlyPlayedItem.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
      _recentlyPlayed = parsed;
      _hasLoadedRecentlyPlayed = true;
    } catch (_) {
      _recentlyPlayed = const [];
      _hasLoadedRecentlyPlayed = true;
    } finally {
      _isLoadingRecentlyPlayed = false;
      notifyListeners();
    }
  }

  Future<void> loadTrendingArtists({bool forceRefresh = false}) async {
    if (_isLoadingTrendingArtists) return;
    if (!forceRefresh && _hasLoadedTrendingArtists) return;

    _isLoadingTrendingArtists = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAccessToken();
      final useAuth =
          token != null && token.trim().isNotEmpty;

      final response = await _requester.getJson(
        '/api/v1/discover/trending/artists',
        (json) => json,
        queryParameters: const {'page': 1, 'pageSize': 24},
        authenticate: useAuth,
      );

      final rawItems = response['items'];
      final parsed = <TrendingArtist>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map<String, dynamic>) {
            parsed.add(TrendingArtist.fromJson(item));
          } else if (item is Map) {
            parsed.add(
              TrendingArtist.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
      _trendingArtists = parsed;
      _hasLoadedTrendingArtists = true;
    } catch (_) {
      _trendingArtists = const [];
      _hasLoadedTrendingArtists = true;
    } finally {
      _isLoadingTrendingArtists = false;
      notifyListeners();
    }
  }

  Future<void> refreshHome() async {
    await Future.wait([
      loadRecentlyPlayed(forceRefresh: true),
      loadTrendingArtists(forceRefresh: true),
    ]);
  }
}
