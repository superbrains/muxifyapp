import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/models/spotlight_tab.dart';
import 'package:muxify/features/home/models/tab_option.dart';
import 'package:muxify/features/home/models/track_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/widgets/featured_playlist_section.dart';
import 'package:muxify/features/home/widgets/followed_section.dart';
import 'package:muxify/features/home/widgets/home_header.dart';
import 'package:muxify/features/home/widgets/home_menu_drawer.dart';
import 'package:muxify/features/home/widgets/popular_releases_section.dart';
import 'package:muxify/features/home/widgets/recently_played_section.dart';
import 'package:muxify/features/home/widgets/recently_played_videos_section.dart';
import 'package:muxify/features/home/widgets/spotlight_section.dart';
import 'package:muxify/features/home/widgets/trending_artists_section.dart';
import 'package:muxify/features/home/widgets/trending_videos_section.dart';
import 'package:muxify/features/home/widgets/video_followed_section.dart';
import 'package:muxify/features/home/widgets/video_popular_new_releases_section.dart';
import 'package:muxify/features/home/widgets/video_spotlight_section.dart';
import 'package:muxify/features/home/widgets/video_tabs_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTab = 'Music';
  String _selectedCategoryId = 'trending';
  String _selectedSpotlightTabId = 'spotlight';
  String _selectedVideoTabId = 'content_videos';
  String _selectedVideoSpotlightTabId = 'spotlight';

  final List<TabOption> _toggleOptions = [
    TabOption(title: 'Music', icon: Icons.music_note),
    TabOption(title: 'Videos', icon: Icons.play_circle_outline),
    TabOption(title: 'DJ Mix', icon: Icons.album_outlined),
    TabOption(title: 'Podcast', icon: Icons.mic),
  ];

  final List<CategoryTab> _categoryTabs = [
    CategoryTab(id: 'trending', title: 'Trending', icon: Icons.trending_up),
    CategoryTab(
      id: 'hot_release',
      title: 'Hot Release',
      icon: Icons.local_fire_department,
    ),
    CategoryTab(id: 'top_chart', title: 'Top Chart', icon: Icons.bar_chart),
    CategoryTab(id: 'new_release', title: 'New Release', icon: Icons.fiber_new),
  ];

  // Music side: Spotlight (curated) + two gift leaderboards (artist-level,
  // track-level) + Top Giver. The "Most Gifted" tab was split into artist/track
  // and "Most Giver" was dropped (it duplicated Top Giver).
  final List<SpotlightTab> _musicSpotlightTabs = [
    SpotlightTab(id: 'spotlight', title: 'Spotlight', icon: Icons.wb_sunny),
    SpotlightTab(
      id: 'most_gifted_artist',
      title: 'Most Gifted Artist',
      icon: Icons.workspace_premium,
    ),
    SpotlightTab(
      id: 'most_gifted_track',
      title: 'Most Gifted Track',
      icon: Icons.card_giftcard,
    ),
    SpotlightTab(
      id: 'top_giver',
      title: 'Top Giver',
      icon: Icons.volunteer_activism,
    ),
  ];

  // Video side mirrors the music tabs at the creator/video level.
  final List<SpotlightTab> _videoSpotlightTabs = [
    SpotlightTab(id: 'spotlight', title: 'Spotlight', icon: Icons.wb_sunny),
    SpotlightTab(
      id: 'most_gifted_creator',
      title: 'Most Gifted Creator',
      icon: Icons.workspace_premium,
    ),
    SpotlightTab(
      id: 'most_gifted_video',
      title: 'Most Gifted Video',
      icon: Icons.card_giftcard,
    ),
    SpotlightTab(
      id: 'top_giver',
      title: 'Top Giver',
      icon: Icons.volunteer_activism,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final home = context.read<HomeProvider>();
      home.loadRecentlyPlayed();
      home.loadTrendingArtists();
      home.loadFeaturedPlaylists();
      home.loadPopularNewReleases();
      home.loadFollowed();
      home.loadCategoryTab(_selectedCategoryId);
      home.loadSpotlightTab(_selectedSpotlightTabId);
      // Video-tab feeds — kicked off on first frame so the tab is ready
      // when the user switches over.
      home.loadVideoCategoryTab(_selectedCategoryId);
      home.loadPopularReleaseVideos();
      home.loadFollowedVideos();
      home.loadVideoSpotlightTab(_selectedVideoSpotlightTabId);
    });
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _pushArtistProfile(
    BuildContext context,
    TrendingArtist artist, {
    String? mediaType,
  }) {
    final queryParameters = <String, String>{
      'artistId': artist.id,
      'artistName': artist.name,
      'followerCount': artist.followerCount.toString(),
      'isFollowing': artist.isFollowing.toString(),
      'isVerified': artist.isVerified.toString(),
      if ((artist.imageUrl ?? '').trim().isNotEmpty)
        'coverImageUrl': artist.imageUrl!.trim(),
      if ((mediaType ?? '').trim().isNotEmpty) 'mediaType': mediaType!.trim(),
    };

    final uri = Uri(
      path: AppRouter.artistProfile,
      queryParameters: queryParameters,
    );
    context.push(uri.toString());
  }

  void _openPlayer({
    required String trackId,
    required String title,
    required String artistName,
    String? artistId,
    String? coverUrl,
    bool isUnlocked = true,
    int? unlockCostCoins,
  }) {
    final id = trackId.trim();
    if (id.isEmpty) return;
    final cover = coverUrl?.trim();
    final artist = artistId?.trim();
    final uri = Uri(
      path: AppRouter.musicPlayer,
      queryParameters: {
        'trackId': id,
        'title': title,
        'artistName': artistName,
        if (artist != null && artist.isNotEmpty) 'artistId': artist,
        if (cover != null && cover.isNotEmpty) 'backgroundImageUrl': cover,
        'isUnlocked': '$isUnlocked',
        if (unlockCostCoins != null)
          'unlockCostCoins': '$unlockCostCoins',
      },
    );
    context.push(uri.toString());
  }

  void _openRecentlyPlayed(RecentlyPlayedItem item) {
    if (item.id.isEmpty) return;
    _openPlayer(
      trackId: item.id,
      title: item.title,
      artistName: item.artist ?? '',
      coverUrl: item.imageUrl,
    );
  }

  void _openFollowed(FollowedItem item) {
    _openPlayer(
      trackId: item.id,
      title: item.title,
      artistName: item.artist,
      artistId: item.artistId,
      coverUrl: item.imageUrl,
      isUnlocked: item.isUnlocked,
    );
  }

  void _openNewRelease(NewReleaseItem item) {
    _openPlayer(
      trackId: item.id,
      title: item.albumName,
      artistName: item.artistName,
      artistId: item.artistId,
      coverUrl: item.imageUrl,
      isUnlocked: item.isUnlocked,
      unlockCostCoins: item.unlockCostCoins,
    );
  }

  /// Routes a spotlight card tap by what it represents: a track/curated item
  /// opens the player, an artist opens their profile, a top giver opens the fan
  /// profile.
  void _openSpotlightItem(SpotlightItem item) {
    switch (item.kind) {
      case SpotlightKind.artist:
        _pushArtistProfileById(item.id, item.title, item.imageUrl);
        break;
      case SpotlightKind.giver:
        _pushFanProfile(item.id);
        break;
      case SpotlightKind.video:
        _openVideoPlayer(
          videoId: item.id,
          title: item.title,
          artistName: item.artist,
          artistId: item.artistId,
          thumbnailUrl: item.imageUrl,
          isUnlocked: item.isUnlocked,
        );
        break;
      case SpotlightKind.track:
      case SpotlightKind.curated:
        if (!item.isPlayable) return;
        _openPlayer(
          trackId: item.id,
          title: item.title,
          artistName: item.artist,
          artistId: item.artistId,
          coverUrl: item.imageUrl,
          isUnlocked: item.isUnlocked,
        );
        break;
    }
  }

  void _pushArtistProfileById(String artistId, String name, String? imageUrl) {
    final id = artistId.trim();
    if (id.isEmpty) return;
    final uri = Uri(
      path: AppRouter.artistProfile,
      queryParameters: {
        'artistId': id,
        'artistName': name,
        if ((imageUrl ?? '').trim().isNotEmpty)
          'coverImageUrl': imageUrl!.trim(),
      },
    );
    context.push(uri.toString());
  }

  void _pushFanProfile(String fanId) {
    final id = fanId.trim();
    if (id.isEmpty) return;
    context.push(AppRouter.fanProfileFor(id));
  }

  void _openPlaylistTrack(TrackItem track) {
    _openPlayer(
      trackId: track.id,
      title: track.title,
      artistName: track.artist,
      artistId: track.artistId,
      coverUrl: track.imageUrl,
      isUnlocked: track.isUnlocked,
      unlockCostCoins: track.unlockCostCoins,
    );
  }

  void _openVideoPlayer({
    required String videoId,
    required String title,
    required String artistName,
    String? artistId,
    String? thumbnailUrl,
    bool isUnlocked = true,
  }) {
    final id = videoId.trim();
    if (id.isEmpty) return;
    final thumb = thumbnailUrl?.trim();
    final artist = artistId?.trim();
    final uri = Uri(
      path: AppRouter.videoPlayer,
      queryParameters: {
        'videoId': id,
        'title': title,
        'artistName': artistName,
        if (artist != null && artist.isNotEmpty) 'artistId': artist,
        if (thumb != null && thumb.isNotEmpty) 'thumbnailUrl': thumb,
        'isUnlocked': '$isUnlocked',
      },
    );
    context.push(uri.toString());
  }

  void _openVideoItem(VideoItem item) {
    _openVideoPlayer(
      videoId: item.id,
      title: item.title,
      artistName: item.creator,
      artistId: item.creatorId,
      thumbnailUrl: item.imageUrl,
      isUnlocked: item.isUnlocked,
    );
  }

  void _openRecentlyPlayedVideo(RecentlyPlayedItem item) {
    if (item.id.isEmpty || item.type != 'video') return;
    _openVideoPlayer(
      videoId: item.id,
      title: item.title,
      artistName: item.artist ?? '',
      artistId: item.artistId,
      thumbnailUrl: item.imageUrl,
    );
  }

  void _openVideoSpotlightItem(SpotlightItem item) {
    switch (item.kind) {
      case SpotlightKind.artist:
        _pushArtistProfileById(item.id, item.title, item.imageUrl);
        break;
      case SpotlightKind.giver:
        _pushFanProfile(item.id);
        break;
      case SpotlightKind.track:
      case SpotlightKind.video:
      case SpotlightKind.curated:
        if (!item.isPlayable) return;
        _openVideoPlayer(
          videoId: item.id,
          title: item.title,
          artistName: item.artist,
          artistId: item.artistId,
          thumbnailUrl: item.imageUrl,
          isUnlocked: item.isUnlocked,
        );
        break;
    }
  }

  Future<void> _openCategoryPlaylist(PlaylistItem playlist) async {
    if (playlist.tracks.isEmpty) {
      // Fallback: deep link into the FeaturedPlaylistScreen for this category.
      final uri = Uri(
        path: AppRouter.trending,
        queryParameters: {'tabId': _selectedCategoryId},
      );
      context.push(uri.toString());
      return;
    }

    // Cap to top 10 from the in-memory genre group and queue them up.
    final source = playlist.tracks.take(10).toList();
    final fallbackCover = playlist.imageUrl?.trim().isNotEmpty == true
        ? playlist.imageUrl
        : null;
    final tracks = source
        .map(
          (t) => Track(
            id: t.id,
            title: t.title,
            artist: t.artist,
            artistId: t.artistId,
            artworkUrl: (t.imageUrl?.trim().isNotEmpty == true)
                ? t.imageUrl
                : fallbackCover,
            isUnlocked: t.isUnlocked,
            unlockCostCoins: t.unlockCostCoins,
          ),
        )
        .toList();

    // Open the player immediately so the user sees the branded loader while
    // audio resolves in the background — navigation is no longer blocked
    // behind stream-URL resolution for the whole queue.
    final first = source.first;
    _openPlayer(
      trackId: first.id,
      title: first.title,
      artistName: first.artist,
      artistId: first.artistId,
      coverUrl: first.imageUrl ?? playlist.imageUrl,
      isUnlocked: first.isUnlocked,
      unlockCostCoins: first.unlockCostCoins,
    );

    // Fire-and-forget: the player hydrates from the global AudioProvider and
    // shows the branded loader until the first source is ready.
    unawaited(context.read<AudioProvider>().loadAndPlay(tracks));
  }

  // ---------------------------------------------------------------------------
  // Tab content
  // ---------------------------------------------------------------------------

  Widget _buildTabContent(HomeProvider homeProvider) {
    switch (_selectedTab) {
      case 'Music':
        return _buildMusicContent(homeProvider);
      case 'Videos':
        return _buildVideosContent(homeProvider);
      case 'DJ Mix':
        return _buildDjMixContent(homeProvider);
      case 'Podcast':
        return _buildPodcastContent(homeProvider);
      default:
        return _buildMusicContent(homeProvider);
    }
  }

  Widget _buildMusicContent(HomeProvider homeProvider) {
    final recentlyPlayedMusic = homeProvider.recentlyPlayedMusic;
    final showRecentlyPlayed = homeProvider.isLoadingRecentlyPlayed ||
        (homeProvider.hasLoadedRecentlyPlayed &&
            recentlyPlayedMusic.isNotEmpty);

    final showTrendingArtists = homeProvider.isLoadingTrendingArtists ||
        (homeProvider.hasLoadedTrendingArtists &&
            homeProvider.trendingArtists.isNotEmpty);

    final categoryCards = homeProvider.categoryCards(_selectedCategoryId);
    final categoryLoading = homeProvider.isLoadingCategory(_selectedCategoryId);
    final showCategorySection = categoryLoading || categoryCards.isNotEmpty;

    final featuredLoading = homeProvider.isLoadingFeaturedPlaylists;
    final featured = homeProvider.featuredPlaylists;
    final showFeaturedSection = featuredLoading || featured.isNotEmpty;

    final popular = homeProvider.popularNewReleases;
    final popularLoading = homeProvider.isLoadingPopularNewReleases;
    final showPopular = popularLoading || popular.isNotEmpty;

    final spotlightItems = homeProvider.spotlightForTab(_selectedSpotlightTabId);
    final spotlightLoading =
        homeProvider.isLoadingSpotlightTab(_selectedSpotlightTabId);

    final followed = homeProvider.followed;
    final followedLoading = homeProvider.isLoadingFollowed;
    final showFollowed = followedLoading || followed.isNotEmpty;

    // Video sections that share the same _creatorCategory filter — so a
    // creator's audio AND video output appears under their tab. Each section
    // is shown only when there's something to render (no loading skeletons,
    // since the music sections already provide that affordance).
    final categoryVideos = homeProvider.videosForCategory(_selectedCategoryId);
    final popularReleaseVideos = homeProvider.popularReleaseVideos;
    final followedVideos = homeProvider.followedVideos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        30.column,
        if (homeProvider.isLoadingRecentlyPlayed)
          RecentlyPlayedSection(items: const [], isLoading: true)
        else if (homeProvider.hasLoadedRecentlyPlayed &&
            recentlyPlayedMusic.isNotEmpty)
          RecentlyPlayedSection(
            items: recentlyPlayedMusic,
            onItemTap: _openRecentlyPlayed,
          ),
        if (showRecentlyPlayed) 30.column,
        if (showTrendingArtists)
          TrendingArtistsSection(
            artists: homeProvider.trendingArtists,
            title: 'Trending artists',
            showLeadingIcon: true,
            isLoading: homeProvider.isLoadingTrendingArtists,
            onArtistTap: (artist) => _pushArtistProfile(context, artist),
          ),
        if (showTrendingArtists) 30.column,

        // Category tabs that drive the sections directly below. Both the
        // music category cards AND the Trending-videos grid filter on this
        // same Trending/Hot/Top/New selection.
        CategoryTabsSection(
          categories: _categoryTabs,
          selectedCategoryId: _selectedCategoryId,
          onCategoryChanged: (categoryId) {
            setState(() => _selectedCategoryId = categoryId);
            final home = context.read<HomeProvider>();
            home.loadCategoryTab(categoryId);
            home.loadVideoCategoryTab(categoryId);
          },
        ),
        24.column,

        if (showCategorySection)
          FeaturedPlaylistSection(
            playlists: categoryCards,
            isLoading: categoryLoading,
            onPlaylistTap: _openCategoryPlaylist,
            onTrackTap: _openPlaylistTrack,
            onSeeAll: () {
              final uri = Uri(
                path: AppRouter.trending,
                queryParameters: {'tabId': _selectedCategoryId},
              );
              context.push(uri.toString());
            },
          ),
        if (showCategorySection) 20.column,

        // Trending-videos grid for the same Trending/Hot/Top/New selection,
        // narrowed to the active creator-category (Artist / DJ / Podcaster).
        if (categoryVideos.isNotEmpty) ...[
          TrendingVideosSection(
            items: categoryVideos,
            onItemTap: _openVideoItem,
          ),
          30.column,
        ],

        // Curated featured playlists (always-on, below the category-driven cards).
        if (showFeaturedSection) ...[
          FeaturedPlaylistSection(
            playlists: featured,
            isLoading: featuredLoading,
            onPlaylistTap: _openCategoryPlaylist,
            onTrackTap: _openPlaylistTrack,
            onSeeAll: () {
              final uri = Uri(
                path: AppRouter.trending,
                queryParameters: {'tabId': _selectedCategoryId},
              );
              context.push(uri.toString());
            },
          ),
          20.column,
        ],

        if (showPopular)
          PopularReleasesSection(
            title: 'Popular New Releases',
            releases: popular,
            isLoading: popularLoading,
            onItemTap: _openNewRelease,
          ),
        if (showPopular) 32.column,

        if (popularReleaseVideos.isNotEmpty) ...[
          VideoPopularNewReleasesSection(
            items: popularReleaseVideos,
            onItemTap: _openVideoItem,
          ),
          32.column,
        ],

        SpotlightSection(
          tabs: _musicSpotlightTabs,
          selectedTabId: _selectedSpotlightTabId,
          onTabChanged: (tabId) {
            setState(() => _selectedSpotlightTabId = tabId);
            context.read<HomeProvider>().loadSpotlightTab(tabId);
          },
          items: spotlightItems,
          isLoading: spotlightLoading,
          showPeriodToggle: _selectedSpotlightTabId != 'spotlight',
          selectedPeriod: homeProvider.spotlightPeriod,
          onPeriodChanged: (period) {
            context.read<HomeProvider>().setSpotlightPeriod(period);
            context.read<HomeProvider>().loadSpotlightTab(
                  _selectedSpotlightTabId,
                  forceRefresh: true,
                );
          },
          onItemTap: _openSpotlightItem,
          onUnlockTap: _openSpotlightItem,
        ),
        32.column,

        if (showFollowed)
          FollowedSection(
            title: 'From those you follow',
            items: followed,
            isLoading: followedLoading,
            onItemTap: _openFollowed,
          ),
        if (showFollowed) 32.column,

        if (followedVideos.isNotEmpty) ...[
          VideoFollowedSection(
            title: 'Videos from those you follow',
            items: followedVideos,
            onItemTap: _openVideoItem,
          ),
          32.column,
        ],
      ],
    );
  }

  Widget _buildVideosContent(HomeProvider homeProvider) {
    final showTrendingArtistsSection =
        homeProvider.isLoadingTrendingArtists ||
            (homeProvider.hasLoadedTrendingArtists &&
                homeProvider.trendingArtists.isNotEmpty);

    final recentVideos = homeProvider.recentlyPlayedVideos;
    final showRecentVideos = homeProvider.isLoadingRecentlyPlayed ||
        (homeProvider.hasLoadedRecentlyPlayed && recentVideos.isNotEmpty);

    final categoryVideos = homeProvider.videosForCategory(_selectedCategoryId);
    final categoryVideosLoading =
        homeProvider.isLoadingVideoCategory(_selectedCategoryId);
    final showCategoryVideos =
        categoryVideosLoading || categoryVideos.isNotEmpty;

    final popularVideos = homeProvider.popularReleaseVideos;
    final popularVideosLoading = homeProvider.isLoadingPopularReleaseVideos;
    final showPopularVideos = popularVideosLoading || popularVideos.isNotEmpty;

    final spotlightVideoItems =
        homeProvider.videoSpotlightForTab(_selectedVideoSpotlightTabId);
    final spotlightVideosLoading =
        homeProvider.isLoadingVideoSpotlightTab(_selectedVideoSpotlightTabId);
    final showSpotlightVideos =
        spotlightVideosLoading || spotlightVideoItems.isNotEmpty;

    final followedVideos = homeProvider.followedVideos;
    final followedVideosLoading = homeProvider.isLoadingFollowedVideos;
    final showFollowedVideos =
        followedVideosLoading || followedVideos.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        19.column,
        Padding(
          padding: EdgeInsets.only(right: 24.padding),
          child: VideoTabsSection(
            selectedTabId: _selectedVideoTabId,
            onTabChanged: (tabId) {
              setState(() => _selectedVideoTabId = tabId);
              // Content Videos -> Creator uploads; Music Videos -> Artist uploads.
              final role = tabId == 'music_videos' ? 'artist' : 'creator';
              final home = context.read<HomeProvider>();
              home.setVideoCreatorCategory(role);
              // Re-fetch the video sections under the new uploader role.
              home.loadVideoCategoryTab(_selectedCategoryId);
              home.loadPopularReleaseVideos();
              home.loadFollowedVideos();
              home.loadVideoSpotlightTab(_selectedVideoSpotlightTabId);
            },
          ),
        ),
        30.column,
        if (showRecentVideos)
          RecentlyPlayedVideosSection(
            items: recentVideos
                .map((rp) => VideoItem(
                      id: rp.id,
                      title: rp.title,
                      imageUrl: (rp.imageUrl == null || rp.imageUrl!.isEmpty)
                          ? 'assets/pngs/release_placeholder.png'
                          : rp.imageUrl!,
                      creator: rp.artist ?? '',
                      creatorImageUrl: '',
                    ))
                .toList(growable: false),
            onItemTap: (vi) => _openRecentlyPlayedVideo(
              recentVideos.firstWhere((r) => r.id == vi.id),
            ),
          ),
        if (showRecentVideos) 30.column,
        if (showTrendingArtistsSection)
          TrendingArtistsSection(
            artists: homeProvider.trendingArtists,
            title: 'Trending artists',
            showLeadingIcon: true,
            isLoading: homeProvider.isLoadingTrendingArtists,
            mediaType: 'Videos',
            onArtistTap: (artist) =>
                _pushArtistProfile(context, artist, mediaType: 'Videos'),
          ),
        if (showTrendingArtistsSection) 30.column,
        CategoryTabsSection(
          categories: _categoryTabs,
          selectedCategoryId: _selectedCategoryId,
          onCategoryChanged: (categoryId) {
            setState(() => _selectedCategoryId = categoryId);
            context.read<HomeProvider>().loadVideoCategoryTab(categoryId);
          },
        ),
        24.column,
        if (showCategoryVideos)
          TrendingVideosSection(
            items: categoryVideos,
            onItemTap: _openVideoItem,
          ),
        if (showCategoryVideos) 30.column,
        if (showPopularVideos)
          VideoPopularNewReleasesSection(
            items: popularVideos,
            onItemTap: _openVideoItem,
          ),
        if (showPopularVideos) 30.column,
        if (showSpotlightVideos)
          VideoSpotlightSection(
            tabs: _videoSpotlightTabs,
            selectedTabId: _selectedVideoSpotlightTabId,
            onTabChanged: (tabId) {
              setState(() => _selectedVideoSpotlightTabId = tabId);
              context.read<HomeProvider>().loadVideoSpotlightTab(tabId);
            },
            items: spotlightVideoItems,
            showPeriodToggle: _selectedVideoSpotlightTabId != 'spotlight',
            selectedPeriod: homeProvider.videoSpotlightPeriod,
            onPeriodChanged: (period) {
              context.read<HomeProvider>().setVideoSpotlightPeriod(period);
              context.read<HomeProvider>().loadVideoSpotlightTab(
                    _selectedVideoSpotlightTabId,
                    forceRefresh: true,
                  );
            },
            onItemTap: _openVideoSpotlightItem,
            onUnlockTap: _openVideoSpotlightItem,
          ),
        if (showSpotlightVideos) 30.column,
        if (showFollowedVideos)
          VideoFollowedSection(
            title: 'From those you follow',
            items: followedVideos,
            onItemTap: _openVideoItem,
          ),
        100.column,
      ],
    );
  }

  // DJ Mix and Podcast reuse the music layout — the difference between the
  // tabs comes from the creator-category filter set on HomeProvider when the
  // tab is selected (see HomeHeader.onTabChanged below).
  Widget _buildDjMixContent(HomeProvider homeProvider) =>
      _buildMusicContent(homeProvider);

  Widget _buildPodcastContent(HomeProvider homeProvider) =>
      _buildMusicContent(homeProvider);

  String? _creatorCategoryForTab(String tab) {
    switch (tab) {
      case 'Music':
        return 'artist';
      case 'DJ Mix':
        return 'dj';
      case 'Podcast':
        return 'podcaster';
      case 'Videos':
        return 'creator';
      default:
        return null;
    }
  }

  /// Re-fires every category-scoped loader (audio + video) after a tab switch.
  /// Music/DJ Mix/Podcast tabs render both audio and video sections from
  /// [_buildMusicContent], and the Videos tab re-uses the same video loaders
  /// from [_buildVideosContent], so we kick all of them off regardless of
  /// which tab is now active.
  void _reloadAllSectionsForCurrentTab(HomeProvider home) {
    home.loadRecentlyPlayed();
    home.loadTrendingArtists();
    home.loadFeaturedPlaylists();
    home.loadPopularNewReleases();
    home.loadFollowed();
    home.loadCategoryTab(_selectedCategoryId);
    home.loadSpotlightTab(_selectedSpotlightTabId);
    home.loadVideoCategoryTab(_selectedCategoryId);
    home.loadPopularReleaseVideos();
    home.loadFollowedVideos();
    home.loadVideoSpotlightTab(_selectedVideoSpotlightTabId);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final isPhoneLayout = MediaQuery.sizeOf(context).width < 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: isPhoneLayout ? const HomeMenuDrawer() : null,
      body: Column(
        children: [
          HomeHeader(
            selectedTab: _selectedTab,
            toggleOptions: _toggleOptions,
            onTabChanged: (tab) {
              setState(() => _selectedTab = tab);
              final home = context.read<HomeProvider>();
              if (tab == 'Videos') {
                // The Videos tab keeps the audio creator-category at 'creator'
                // (so recently-played still resolves to videos) while the
                // Content/Music sub-tabs drive the video uploader-role filter.
                final role =
                    _selectedVideoTabId == 'music_videos' ? 'artist' : 'creator';
                home.setVideoCreatorCategory(role);
                if (home.creatorCategory != 'creator') {
                  home.setCreatorCategory('creator');
                }
                home.setOnVideosTab(true);
                _reloadAllSectionsForCurrentTab(home);
                return;
              }
              home.setOnVideosTab(false);
              final category = _creatorCategoryForTab(tab);
              if (category == null) return;
              if (home.creatorCategory == category) return;
              home.setCreatorCategory(category);
              _reloadAllSectionsForCurrentTab(home);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<HomeProvider>().refreshHome(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 24.padding),
                child: _buildTabContent(homeProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
