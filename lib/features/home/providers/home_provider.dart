import 'package:flutter/foundation.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';
import 'package:muxify/features/home/data/music_feed_repository.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    ApiRequester? requester,
    MusicFeedRepository? feedRepository,
  })  : _requester = requester ?? ApiRequester(),
        _feed = feedRepository ?? MusicFeedRepository(requester: requester);

  final ApiRequester _requester;
  final MusicFeedRepository _feed;

  // ---- Recently Played ------------------------------------------------------
  List<RecentlyPlayedItem> _recentlyPlayed = const [];
  bool _isLoadingRecentlyPlayed = false;
  bool _hasLoadedRecentlyPlayed = false;
  List<RecentlyPlayedItem> get recentlyPlayed => _recentlyPlayed;
  bool get isLoadingRecentlyPlayed => _isLoadingRecentlyPlayed;
  bool get hasLoadedRecentlyPlayed => _hasLoadedRecentlyPlayed;

  // ---- Trending Artists -----------------------------------------------------
  List<TrendingArtist> _trendingArtists = const [];
  bool _isLoadingTrendingArtists = false;
  bool _hasLoadedTrendingArtists = false;
  List<TrendingArtist> get trendingArtists => _trendingArtists;
  bool get isLoadingTrendingArtists => _isLoadingTrendingArtists;
  bool get hasLoadedTrendingArtists => _hasLoadedTrendingArtists;

  // ---- Featured Playlists (always-on carousel of curated playlists) --------
  List<PlaylistItem> _featuredPlaylists = const [];
  bool _isLoadingFeaturedPlaylists = false;
  bool _hasLoadedFeaturedPlaylists = false;
  List<PlaylistItem> get featuredPlaylists => _featuredPlaylists;
  bool get isLoadingFeaturedPlaylists => _isLoadingFeaturedPlaylists;
  bool get hasLoadedFeaturedPlaylists => _hasLoadedFeaturedPlaylists;

  // ---- Category tab content (Trending / Hot Release / Top Chart / New) ----
  // Cache one playlist-card list per tab id so switching tabs is instant after
  // the first load.
  final Map<String, List<PlaylistItem>> _categoryCardsByTab = {};
  final Set<String> _loadingCategoryTabs = {};
  String _activeCategoryId = 'trending';
  String get activeCategoryId => _activeCategoryId;
  bool isLoadingCategory(String tabId) => _loadingCategoryTabs.contains(tabId);
  List<PlaylistItem> categoryCards(String tabId) =>
      _categoryCardsByTab[tabId] ?? const [];

  // ---- Popular New Releases (album/track horizontal scroll) ----------------
  List<NewReleaseItem> _popularNewReleases = const [];
  bool _isLoadingPopularNewReleases = false;
  bool _hasLoadedPopularNewReleases = false;
  List<NewReleaseItem> get popularNewReleases => _popularNewReleases;
  bool get isLoadingPopularNewReleases => _isLoadingPopularNewReleases;
  bool get hasLoadedPopularNewReleases => _hasLoadedPopularNewReleases;

  // ---- Spotlight (4 sub-tabs: Spotlight / Most Gifted / Top Giver / Most Giver)
  final Map<String, List<SpotlightItem>> _spotlightByTab = {};
  final Set<String> _loadingSpotlightTabs = {};
  String _activeSpotlightId = 'spotlight';
  String get activeSpotlightId => _activeSpotlightId;
  bool isLoadingSpotlightTab(String tabId) =>
      _loadingSpotlightTabs.contains(tabId);
  List<SpotlightItem> spotlightForTab(String tabId) =>
      _spotlightByTab[tabId] ?? const [];

  // ---- From Those You Follow ----------------------------------------------
  List<FollowedItem> _followed = const [];
  bool _isLoadingFollowed = false;
  bool _hasLoadedFollowed = false;
  List<FollowedItem> get followed => _followed;
  bool get isLoadingFollowed => _isLoadingFollowed;
  bool get hasLoadedFollowed => _hasLoadedFollowed;

  // ===========================================================================
  // Loaders
  // ===========================================================================

  Future<void> loadRecentlyPlayed({bool forceRefresh = false}) async {
    if (_isLoadingRecentlyPlayed) return;
    if (!forceRefresh && _hasLoadedRecentlyPlayed) return;

    _isLoadingRecentlyPlayed = true;
    notifyListeners();

    try {
      final response = await _requester.getJson(
        ApiConstants.feedRecentlyPlayedPath,
        (json) => json,
        queryParameters: const {'pageSize': '5'},
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
    } catch (e, st) {
      Logger.error('loadRecentlyPlayed failed', e, st);
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
      final useAuth = token != null && token.trim().isNotEmpty;

      final response = await _requester.getJson(
        ApiConstants.trendingArtistsPath,
        (json) => json,
        queryParameters: const {'page': '1', 'pageSize': '24'},
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
    } catch (e, st) {
      Logger.error('loadTrendingArtists failed', e, st);
      _trendingArtists = const [];
      _hasLoadedTrendingArtists = true;
    } finally {
      _isLoadingTrendingArtists = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedPlaylists({bool forceRefresh = false}) async {
    if (_isLoadingFeaturedPlaylists) return;
    if (!forceRefresh && _hasLoadedFeaturedPlaylists) return;

    _isLoadingFeaturedPlaylists = true;
    notifyListeners();

    try {
      final dtos = await _feed.getFeaturedPlaylists(pageSize: 10);
      _featuredPlaylists =
          dtos.map(PlaylistItem.fromFeedPlaylist).toList(growable: false);
      _hasLoadedFeaturedPlaylists = true;
    } catch (e, st) {
      Logger.error('loadFeaturedPlaylists failed', e, st);
      _featuredPlaylists = const [];
      _hasLoadedFeaturedPlaylists = true;
    } finally {
      _isLoadingFeaturedPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularNewReleases({bool forceRefresh = false}) async {
    if (_isLoadingPopularNewReleases) return;
    if (!forceRefresh && _hasLoadedPopularNewReleases) return;

    _isLoadingPopularNewReleases = true;
    notifyListeners();

    try {
      final dtos = await _feed.getNewReleases(days: 30, pageSize: 10);
      _popularNewReleases =
          dtos.map(NewReleaseItem.fromFeedTrack).toList(growable: false);
      _hasLoadedPopularNewReleases = true;
    } catch (e, st) {
      Logger.error('loadPopularNewReleases failed', e, st);
      _popularNewReleases = const [];
      _hasLoadedPopularNewReleases = true;
    } finally {
      _isLoadingPopularNewReleases = false;
      notifyListeners();
    }
  }

  Future<void> loadFollowed({bool forceRefresh = false}) async {
    if (_isLoadingFollowed) return;
    if (!forceRefresh && _hasLoadedFollowed) return;

    _isLoadingFollowed = true;
    notifyListeners();

    try {
      final dtos = await _feed.getFromFollowing(pageSize: 12);
      _followed =
          dtos.map(FollowedItem.fromFeedTrack).toList(growable: false);
      _hasLoadedFollowed = true;
    } catch (e, st) {
      Logger.error('loadFollowed failed', e, st);
      _followed = const [];
      _hasLoadedFollowed = true;
    } finally {
      _isLoadingFollowed = false;
      notifyListeners();
    }
  }

  /// Loads tracks for a category tab and groups them into per-genre playlist
  /// cards. The result is cached per tab id so subsequent taps are instant.
  Future<void> loadCategoryTab(String tabId, {bool forceRefresh = false}) async {
    _activeCategoryId = tabId;
    if (_loadingCategoryTabs.contains(tabId)) {
      notifyListeners();
      return;
    }
    if (!forceRefresh && _categoryCardsByTab.containsKey(tabId)) {
      notifyListeners();
      return;
    }

    _loadingCategoryTabs.add(tabId);
    notifyListeners();

    try {
      final tracks = await _fetchTracksForCategory(tabId);
      _categoryCardsByTab[tabId] = _groupTracksByGenre(tabId, tracks);
    } catch (e, st) {
      Logger.error('loadCategoryTab($tabId) failed', e, st);
      _categoryCardsByTab[tabId] = const [];
    } finally {
      _loadingCategoryTabs.remove(tabId);
      notifyListeners();
    }
  }

  Future<void> loadSpotlightTab(String tabId, {bool forceRefresh = false}) async {
    _activeSpotlightId = tabId;
    if (_loadingSpotlightTabs.contains(tabId)) {
      notifyListeners();
      return;
    }
    if (!forceRefresh && _spotlightByTab.containsKey(tabId)) {
      notifyListeners();
      return;
    }

    _loadingSpotlightTabs.add(tabId);
    notifyListeners();

    try {
      final items = await _fetchSpotlightItems(tabId);
      _spotlightByTab[tabId] = items;
    } catch (e, st) {
      Logger.error('loadSpotlightTab($tabId) failed', e, st);
      _spotlightByTab[tabId] = const [];
    } finally {
      _loadingSpotlightTabs.remove(tabId);
      notifyListeners();
    }
  }

  Future<void> refreshHome() async {
    await Future.wait([
      loadRecentlyPlayed(forceRefresh: true),
      loadTrendingArtists(forceRefresh: true),
      loadFeaturedPlaylists(forceRefresh: true),
      loadPopularNewReleases(forceRefresh: true),
      loadFollowed(forceRefresh: true),
      loadCategoryTab(_activeCategoryId, forceRefresh: true),
      loadSpotlightTab(_activeSpotlightId, forceRefresh: true),
    ]);
  }

  // ===========================================================================
  // Internal helpers
  // ===========================================================================

  Future<List<FeedTrackDto>> _fetchTracksForCategory(String tabId) async {
    switch (tabId) {
      case 'trending':
        return _feed.getTrendingTracks(period: 'week', pageSize: 24);
      case 'hot_release':
        return _feed.getHotReleases(days: 14, pageSize: 24);
      case 'top_chart':
        return _feed.getTopCharts(period: 'all', pageSize: 24);
      case 'new_release':
        return _feed.getNewReleases(days: 30, pageSize: 24);
      default:
        return _feed.getTrendingTracks(period: 'week', pageSize: 24);
    }
  }

  List<PlaylistItem> _groupTracksByGenre(
    String tabId,
    List<FeedTrackDto> tracks,
  ) {
    if (tracks.isEmpty) return const [];

    final buckets = <String, List<FeedTrackDto>>{};
    final order = <String>[];
    for (final t in tracks) {
      final genre = t.genreName?.trim();
      final key = (genre == null || genre.isEmpty) ? 'More' : genre;
      buckets.putIfAbsent(key, () {
        order.add(key);
        return <FeedTrackDto>[];
      }).add(t);
    }

    return order
        .map(
          (key) => PlaylistItem.fromCategory(
            id: '${tabId}__$key',
            title: key,
            sourceTracks: buckets[key]!,
          ),
        )
        .toList(growable: false);
  }

  Future<List<SpotlightItem>> _fetchSpotlightItems(String tabId) async {
    switch (tabId) {
      case 'spotlight':
        final items = await _feed.getSpotlight(take: 5);
        return items.map(SpotlightItem.fromSpotlightDto).toList(growable: false);
      case 'most_gifted':
        final items = await _feed.getMostGifted(period: 'week', pageSize: 10);
        return items.map(SpotlightItem.fromMostGiftedDto).toList(growable: false);
      case 'top_giver':
        final items = await _feed.getTopGivers(period: 'week', pageSize: 10);
        return items.map(SpotlightItem.fromTopGiverDto).toList(growable: false);
      case 'most_giver':
        // No dedicated endpoint yet — reuse top-givers ranked by gift count
        // (the DTO carries totalGiftCount we re-sort on).
        final items = await _feed.getTopGivers(period: 'all', pageSize: 10);
        final sorted = [...items]
          ..sort((a, b) => b.totalGiftCount.compareTo(a.totalGiftCount));
        return sorted.map(SpotlightItem.fromTopGiverDto).toList(growable: false);
      default:
        return const [];
    }
  }
}
