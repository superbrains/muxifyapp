import 'package:flutter/foundation.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_requester.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';
import 'package:muxify/features/home/data/music_feed_repository.dart';
import 'package:muxify/features/home/data/video_feed_repository.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/models/video_item.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    ApiRequester? requester,
    MusicFeedRepository? feedRepository,
    VideoFeedRepository? videoFeedRepository,
  })  : _requester = requester ?? ApiRequester(),
        _feed = feedRepository ?? MusicFeedRepository(requester: requester),
        _videoFeed =
            videoFeedRepository ?? VideoFeedRepository(requester: requester);

  final ApiRequester _requester;
  final MusicFeedRepository _feed;
  final VideoFeedRepository _videoFeed;

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
  // VIDEO TAB STATE
  // ===========================================================================

  /// Creator-category filter applied to every category-scoped feed call —
  /// both audio (tracks) and video. Maps to the backend's `?category=` query
  /// param which narrows results by uploader [UserRole]. One value per top
  /// tab: "artist" = Music, "dj" = DJ Mix, "podcaster" = Podcast,
  /// "creator" = Videos. Switching tabs reassigns this and clears all
  /// category-scoped caches.
  String _creatorCategory = 'artist';
  String get creatorCategory => _creatorCategory;

  /// Uploader-role filter for the two Videos sub-tabs. Unlike [_creatorCategory]
  /// (which the top tab drives for both audio and video), this is set only by
  /// the Content/Music sub-tab toggle and applies exclusively to the video
  /// feeds when [_onVideosTab] is true:
  /// "creator" -> Content Videos (UserRole.Creator uploads)
  /// "artist"  -> Music Videos   (UserRole.Artist uploads)
  /// No VideoType constraint is applied, so all of the role's video types show.
  String _videoCreatorCategory = 'creator';
  String get videoCreatorCategory => _videoCreatorCategory;

  /// True while the "Videos" top tab is active. The video loaders use
  /// [_videoCreatorCategory] for their `category` only on this tab; under the
  /// Music/DJ/Podcast tabs the embedded video sections keep following the audio
  /// [_creatorCategory] so they still show that creator's videos.
  bool _onVideosTab = false;
  bool get onVideosTab => _onVideosTab;

  /// Category string passed to the video feeds: the sub-tab role on the Videos
  /// tab, otherwise the audio creator-category from the active top tab.
  String get _activeVideoCategory =>
      _onVideosTab ? _videoCreatorCategory : _creatorCategory;

  void setOnVideosTab(bool value) {
    if (_onVideosTab == value) return;
    _onVideosTab = value;
    notifyListeners();
  }

  /// Recently-played videos are derived locally from [recentlyPlayed]
  /// (the /feed/recently-played endpoint returns both tracks and videos
  /// with a `type` discriminator).
  List<RecentlyPlayedItem> get recentlyPlayedVideos =>
      _recentlyPlayed.where((it) => it.type == 'video').toList(growable: false);

  /// Recently-played music (audio tracks only) for the Music/DJ Mix/Podcast
  /// tabs. The request is already type-filtered server-side; this guards
  /// against any non-track item slipping into the audio tabs.
  List<RecentlyPlayedItem> get recentlyPlayedMusic =>
      _recentlyPlayed.where((it) => it.type == 'track').toList(growable: false);

  // Per-section state — modeled exactly on the music sections above.
  // Keyed by "$_activeVideoCategory::$_categoryId" for the category-driven section
  // (Trending / Hot Release / Top Chart / New Release).
  final Map<String, List<VideoItem>> _videosByCategoryTab = {};
  final Set<String> _loadingVideoCategoryTabs = {};
  bool isLoadingVideoCategory(String tabId) =>
      _loadingVideoCategoryTabs.contains(_videoCategoryKey(tabId));
  List<VideoItem> videosForCategory(String tabId) =>
      _videosByCategoryTab[_videoCategoryKey(tabId)] ?? const [];
  bool hasLoadedVideoCategory(String tabId) =>
      _videosByCategoryTab.containsKey(_videoCategoryKey(tabId));

  // Popular New Release videos (always 'new-releases' bucket, regardless of selected tab)
  List<VideoItem> _popularReleaseVideos = const [];
  bool _isLoadingPopularReleaseVideos = false;
  bool _hasLoadedPopularReleaseVideos = false;
  List<VideoItem> get popularReleaseVideos => _popularReleaseVideos;
  bool get isLoadingPopularReleaseVideos => _isLoadingPopularReleaseVideos;
  bool get hasLoadedPopularReleaseVideos => _hasLoadedPopularReleaseVideos;

  // Videos from artists the user follows
  List<VideoItem> _followedVideos = const [];
  bool _isLoadingFollowedVideos = false;
  bool _hasLoadedFollowedVideos = false;
  List<VideoItem> get followedVideos => _followedVideos;
  bool get isLoadingFollowedVideos => _isLoadingFollowedVideos;
  bool get hasLoadedFollowedVideos => _hasLoadedFollowedVideos;

  // Video spotlight (4 sub-tabs reuse the music spotlight tab list, but
  // tab id "spotlight" hits /feed/videos/spotlight; "most_gifted" hits
  // /feed/videos/most-gifted; the giver tabs reuse the global top-givers).
  final Map<String, List<SpotlightItem>> _videoSpotlightByTab = {};
  final Set<String> _loadingVideoSpotlightTabs = {};
  bool isLoadingVideoSpotlightTab(String tabId) =>
      _loadingVideoSpotlightTabs.contains(tabId);
  List<SpotlightItem> videoSpotlightForTab(String tabId) =>
      _videoSpotlightByTab[tabId] ?? const [];

  String _videoCategoryKey(String tabId) => '$_activeVideoCategory::$tabId';

  // ===========================================================================
  // Loaders
  // ===========================================================================

  Future<void> loadRecentlyPlayed({bool forceRefresh = false}) async {
    if (_isLoadingRecentlyPlayed) return;
    if (!forceRefresh && _hasLoadedRecentlyPlayed) return;

    _isLoadingRecentlyPlayed = true;
    notifyListeners();

    try {
      // Music / DJ Mix / Podcast tabs play audio (tracks); the Videos tab
      // ("creator" category) plays videos. Filter server-side so each tab
      // gets a full page of its own media type.
      final mediaType = _creatorCategory == 'creator' ? 'video' : 'track';
      final response = await _requester.getJson(
        ApiConstants.feedRecentlyPlayedPath,
        (json) => json,
        queryParameters: {
          'pageSize': '5',
          'category': _creatorCategory,
          'type': mediaType,
        },
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
      // Leave retryable (cold backend / transient error): don't cache an empty
      // result behind the loaded flag, and keep any previously loaded data.
      _hasLoadedRecentlyPlayed = false;
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
        queryParameters: {
          'page': '1',
          'pageSize': '24',
          'category': _creatorCategory,
        },
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
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedTrendingArtists = false;
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
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedFeaturedPlaylists = false;
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
      final dtos = await _feed.getNewReleases(
        days: 30,
        pageSize: 10,
        category: _creatorCategory,
      );
      _popularNewReleases =
          dtos.map(NewReleaseItem.fromFeedTrack).toList(growable: false);
      _hasLoadedPopularNewReleases = true;
    } catch (e, st) {
      Logger.error('loadPopularNewReleases failed', e, st);
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedPopularNewReleases = false;
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
      final dtos = await _feed.getFromFollowing(
        pageSize: 12,
        category: _creatorCategory,
      );
      _followed =
          dtos.map(FollowedItem.fromFeedTrack).toList(growable: false);
      _hasLoadedFollowed = true;
    } catch (e, st) {
      Logger.error('loadFollowed failed', e, st);
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedFollowed = false;
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
      // Don't cache the empty result — leave the tab retryable on next access.
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
      // Don't cache the empty result — leave the tab retryable on next access.
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
      loadVideoCategoryTab(_activeCategoryId, forceRefresh: true),
      loadPopularReleaseVideos(forceRefresh: true),
      loadFollowedVideos(forceRefresh: true),
      loadVideoSpotlightTab(_activeSpotlightId, forceRefresh: true),
    ]);
  }

  // ===========================================================================
  // VIDEO LOADERS
  // ===========================================================================

  /// Switches the creator-category filter (Music / DJ Mix / Podcast / Videos
  /// tabs) and clears every cached category-scoped list — audio AND video —
  /// so the next access re-fetches under the new category. Caller is expected
  /// to trigger the loaders for the currently visible sections after this
  /// returns.
  void setCreatorCategory(String category) {
    final next = category.trim().toLowerCase();
    if (next != 'artist' && next != 'dj' && next != 'podcaster' && next != 'creator') {
      return;
    }
    if (next == _creatorCategory) return;
    _creatorCategory = next;
    // Drop every category-scoped audio cache.
    _categoryCardsByTab.clear();
    _loadingCategoryTabs.clear();
    _spotlightByTab.clear();
    _loadingSpotlightTabs.clear();
    _recentlyPlayed = const [];
    _hasLoadedRecentlyPlayed = false;
    _trendingArtists = const [];
    _hasLoadedTrendingArtists = false;
    _popularNewReleases = const [];
    _hasLoadedPopularNewReleases = false;
    _followed = const [];
    _hasLoadedFollowed = false;
    // Drop every category-scoped video cache.
    _videosByCategoryTab.clear();
    _loadingVideoCategoryTabs.clear();
    _videoSpotlightByTab.clear();
    _loadingVideoSpotlightTabs.clear();
    _popularReleaseVideos = const [];
    _hasLoadedPopularReleaseVideos = false;
    _followedVideos = const [];
    _hasLoadedFollowedVideos = false;
    notifyListeners();
  }

  /// Switches the Videos sub-tab uploader-role filter ("creator" = Content,
  /// "artist" = Music) and clears cached video lists so they re-fetch under the
  /// new role on next access. Does NOT touch [_creatorCategory] or any audio
  /// cache.
  void setVideoCreatorCategory(String category) {
    final next = category.trim().toLowerCase();
    if (next != 'creator' && next != 'artist') return;
    if (next == _videoCreatorCategory) return;
    _videoCreatorCategory = next;
    // Per-category-tab caches are role-scoped via _videoCategoryKey, so they
    // don't need clearing. The non-keyed caches do.
    _popularReleaseVideos = const [];
    _hasLoadedPopularReleaseVideos = false;
    _followedVideos = const [];
    _hasLoadedFollowedVideos = false;
    _videoSpotlightByTab.clear();
    _loadingVideoSpotlightTabs.clear();
    notifyListeners();
  }

  Future<void> loadVideoCategoryTab(String tabId,
      {bool forceRefresh = false}) async {
    final key = _videoCategoryKey(tabId);
    if (_loadingVideoCategoryTabs.contains(key)) {
      notifyListeners();
      return;
    }
    if (!forceRefresh && _videosByCategoryTab.containsKey(key)) {
      notifyListeners();
      return;
    }

    _loadingVideoCategoryTabs.add(key);
    notifyListeners();

    try {
      final dtos = await _fetchVideosForCategory(tabId);
      _videosByCategoryTab[key] =
          dtos.map(VideoItem.fromFeedVideo).toList(growable: false);
    } catch (e, st) {
      Logger.error(
          'loadVideoCategoryTab($tabId, $_activeVideoCategory) failed', e, st);
      // Don't cache the empty result — leave the tab retryable on next access.
    } finally {
      _loadingVideoCategoryTabs.remove(key);
      notifyListeners();
    }
  }

  Future<void> loadPopularReleaseVideos({bool forceRefresh = false}) async {
    if (_isLoadingPopularReleaseVideos) return;
    if (!forceRefresh && _hasLoadedPopularReleaseVideos) return;

    _isLoadingPopularReleaseVideos = true;
    notifyListeners();

    try {
      final dtos = await _videoFeed.getNewReleaseVideos(
        videoType: null,
        category: _activeVideoCategory,
        days: 30,
        pageSize: 10,
      );
      _popularReleaseVideos =
          dtos.map(VideoItem.fromFeedVideo).toList(growable: false);
      _hasLoadedPopularReleaseVideos = true;
    } catch (e, st) {
      Logger.error('loadPopularReleaseVideos failed', e, st);
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedPopularReleaseVideos = false;
    } finally {
      _isLoadingPopularReleaseVideos = false;
      notifyListeners();
    }
  }

  Future<void> loadFollowedVideos({bool forceRefresh = false}) async {
    if (_isLoadingFollowedVideos) return;
    if (!forceRefresh && _hasLoadedFollowedVideos) return;

    _isLoadingFollowedVideos = true;
    notifyListeners();

    try {
      final dtos = await _videoFeed.getVideosFromFollowing(
        videoType: null,
        category: _activeVideoCategory,
        pageSize: 12,
      );
      _followedVideos =
          dtos.map(VideoItem.fromFeedVideo).toList(growable: false);
      _hasLoadedFollowedVideos = true;
    } catch (e, st) {
      Logger.error('loadFollowedVideos failed', e, st);
      // Leave retryable; don't cache an empty result behind the loaded flag.
      _hasLoadedFollowedVideos = false;
    } finally {
      _isLoadingFollowedVideos = false;
      notifyListeners();
    }
  }

  Future<void> loadVideoSpotlightTab(String tabId,
      {bool forceRefresh = false}) async {
    if (_loadingVideoSpotlightTabs.contains(tabId)) {
      notifyListeners();
      return;
    }
    if (!forceRefresh && _videoSpotlightByTab.containsKey(tabId)) {
      notifyListeners();
      return;
    }

    _loadingVideoSpotlightTabs.add(tabId);
    notifyListeners();

    try {
      final items = await _fetchVideoSpotlightItems(tabId);
      _videoSpotlightByTab[tabId] = items;
    } catch (e, st) {
      Logger.error('loadVideoSpotlightTab($tabId) failed', e, st);
      // Don't cache the empty result — leave the tab retryable on next access.
    } finally {
      _loadingVideoSpotlightTabs.remove(tabId);
      notifyListeners();
    }
  }

  Future<List<FeedVideoDto>> _fetchVideosForCategory(String tabId) async {
    final cat = _activeVideoCategory;
    switch (tabId) {
      case 'trending':
        return _videoFeed.getTrendingVideos(
          videoType: null,
          category: cat,
          period: 'week',
          pageSize: 24,
        );
      case 'hot_release':
        return _videoFeed.getHotReleaseVideos(
          videoType: null,
          category: cat,
          days: 14,
          pageSize: 24,
        );
      case 'top_chart':
        return _videoFeed.getTopChartVideos(
          videoType: null,
          category: cat,
          period: 'all',
          pageSize: 24,
        );
      case 'new_release':
        return _videoFeed.getNewReleaseVideos(
          videoType: null,
          category: cat,
          days: 30,
          pageSize: 24,
        );
      default:
        return _videoFeed.getTrendingVideos(
          videoType: null,
          category: cat,
          period: 'week',
          pageSize: 24,
        );
    }
  }

  Future<List<SpotlightItem>> _fetchVideoSpotlightItems(String tabId) async {
    switch (tabId) {
      case 'spotlight':
        final items = await _videoFeed.getVideoSpotlight(take: 5);
        return items
            .map(SpotlightItem.fromSpotlightDto)
            .toList(growable: false);
      case 'most_gifted':
        final items = await _videoFeed.getMostGiftedVideos(
          period: 'week',
          category: _activeVideoCategory,
          pageSize: 10,
        );
        return items.map((dto) {
          final mapped = VideoItem.fromMostGiftedVideo(dto);
          return SpotlightItem(
            id: mapped.id,
            title: mapped.title,
            artist: mapped.creator,
            artistId: dto.artistId,
            playCount: mapped.views ?? '',
            imageUrl: mapped.imageUrl,
            isUnlocked: true,
          );
        }).toList(growable: false);
      case 'top_giver':
      case 'most_giver':
        // No video-specific top-giver leaderboard yet — reuse the global one.
        final items = await _feed.getTopGivers(period: 'week', pageSize: 10);
        return items
            .map(SpotlightItem.fromTopGiverDto)
            .toList(growable: false);
      default:
        return const [];
    }
  }

  // ===========================================================================
  // Internal helpers
  // ===========================================================================

  Future<List<FeedTrackDto>> _fetchTracksForCategory(String tabId) async {
    final cat = _creatorCategory;
    switch (tabId) {
      case 'trending':
        return _feed.getTrendingTracks(period: 'week', pageSize: 24, category: cat);
      case 'hot_release':
        return _feed.getHotReleases(days: 14, pageSize: 24, category: cat);
      case 'top_chart':
        return _feed.getTopCharts(period: 'all', pageSize: 24, category: cat);
      case 'new_release':
        return _feed.getNewReleases(days: 30, pageSize: 24, category: cat);
      default:
        return _feed.getTrendingTracks(period: 'week', pageSize: 24, category: cat);
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
        final items = await _feed.getMostGifted(
          period: 'week',
          pageSize: 10,
          category: _creatorCategory,
        );
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
