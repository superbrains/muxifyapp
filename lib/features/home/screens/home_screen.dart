import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/models/now_playing_item.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/models/spotlight_tab.dart';
import 'package:muxify/features/home/models/tab_option.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/widgets/featured_playlist_section.dart';
import 'package:muxify/features/home/widgets/followed_section.dart';
import 'package:muxify/features/home/widgets/home_header.dart';
import 'package:muxify/features/home/widgets/home_menu_drawer.dart';
import 'package:muxify/features/home/widgets/now_playing_bar.dart';
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
  NowPlayingItem? _currentTrack;

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

  final List<SpotlightTab> _spotlightTabs = [
    SpotlightTab(id: 'spotlight', title: 'Spotlight', icon: Icons.wb_sunny),
    SpotlightTab(
      id: 'most_gifted',
      title: 'Most Gifted',
      icon: Icons.card_giftcard,
    ),
    SpotlightTab(id: 'top_giver', title: 'Top Giver', icon: Icons.trending_up),
    SpotlightTab(id: 'most_giver', title: 'Most Giver', icon: Icons.people),
  ];

  // Videos tab still uses mock content (out of scope for the Music tab wiring).
  final List<VideoItem> _recentlyPlayedVideos = [
    VideoItem(
      id: '1',
      title: 'Mr Funny - Sabinus',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '2',
      title: 'Speed Darling...',
      imageUrl: 'assets/pngs/latest_release.png',
      creator: 'Creator',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '3',
      title: 'Nasboi - When y...',
      imageUrl: 'assets/pngs/new_release.png',
      creator: 'Nasboi',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '4',
      title: 'Sey',
      imageUrl: 'assets/pngs/spotlight_placeholder.png',
      creator: 'Creator',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '5',
      title: 'Artist Profile',
      imageUrl: 'assets/pngs/artist_profile.png',
      creator: 'Creator',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
  ];

  final List<VideoItem> _trendingVideos = [
    VideoItem(
      id: '1',
      title: 'Oga Sabinus and Food',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '2',
      title: 'Food and Karate',
      imageUrl: 'assets/pngs/latest_release.png',
      creator: 'KieKie',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '3',
      title: 'Billionaire Club ft. Olamide',
      imageUrl: 'assets/pngs/release_placeholder.png',
      creator: 'Wizkid',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '4',
      title: 'My crazy chef',
      imageUrl: 'assets/pngs/kiki.png',
      creator: 'Nasboi',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
  ];

  final List<VideoItem> _videoFollowedItems = [
    VideoItem(
      id: '1',
      title: 'Oga Sabinus and Food',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '2',
      title: 'Food and Karate',
      imageUrl: 'assets/pngs/latest_release.png',
      creator: 'KieKie',
      creatorImageUrl: 'assets/pngs/kiki.png',
      views: '250k',
    ),
    VideoItem(
      id: '3',
      title: 'Good Life (Official)',
      imageUrl: 'assets/pngs/kiki.png',
      creator: 'Nasboi',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '4',
      title: 'Oga Sabinus and Food',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
    VideoItem(
      id: '5',
      title: 'Food and Karate',
      imageUrl: 'assets/pngs/latest_release.png',
      creator: 'KieKie',
      creatorImageUrl: 'assets/pngs/kiki.png',
      views: '250k',
    ),
    VideoItem(
      id: '6',
      title: 'Good Life (Official)',
      imageUrl: 'assets/pngs/kiki.png',
      creator: 'Nasboi',
      creatorImageUrl: 'assets/pngs/profile_placeholder.png',
      views: '250k',
    ),
  ];

  final List<SpotlightItem> _videoSpotlightItems = [
    SpotlightItem(
      id: '1',
      title: 'Small Money',
      artist: 'Sabinus',
      playCount: '25,210,000',
      imageUrl: 'assets/pngs/video_spotlight.png',
      isUnlocked: false,
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
    String? coverUrl,
    bool isUnlocked = true,
  }) {
    final id = trackId.trim();
    if (id.isEmpty) return;
    final cover = coverUrl?.trim();
    final uri = Uri(
      path: AppRouter.musicPlayer,
      queryParameters: {
        'trackId': id,
        'title': title,
        'artistName': artistName,
        if (cover != null && cover.isNotEmpty) 'backgroundImageUrl': cover,
        'isUnlocked': '$isUnlocked',
      },
    );
    setState(() {
      _currentTrack = NowPlayingItem(
        id: id,
        title: title,
        artist: artistName,
        albumArtUrl: cover,
        isPlaying: true,
        isUnlocked: isUnlocked,
      );
    });
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
      coverUrl: item.imageUrl,
      isUnlocked: item.isUnlocked,
    );
  }

  void _openNewRelease(NewReleaseItem item) {
    _openPlayer(
      trackId: item.id,
      title: item.albumName,
      artistName: item.artistName,
      coverUrl: item.imageUrl,
    );
  }

  void _openSpotlight(SpotlightItem item) {
    if (!item.isPlayable) return;
    _openPlayer(
      trackId: item.id,
      title: item.title,
      artistName: item.artist,
      coverUrl: item.imageUrl,
      isUnlocked: item.isUnlocked,
    );
  }

  void _openCategoryPlaylist(PlaylistItem playlist) {
    final firstTrack = playlist.tracks.isNotEmpty ? playlist.tracks.first : null;
    if (firstTrack != null) {
      _openPlayer(
        trackId: firstTrack.id,
        title: firstTrack.title,
        artistName: firstTrack.artist,
        coverUrl: firstTrack.imageUrl ?? playlist.imageUrl,
      );
      return;
    }
    // Fallback: deep link into the FeaturedPlaylistScreen for this category.
    final uri = Uri(
      path: AppRouter.trending,
      queryParameters: {'tabId': _selectedCategoryId},
    );
    context.push(uri.toString());
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
    final showRecentlyPlayed = homeProvider.isLoadingRecentlyPlayed ||
        (homeProvider.hasLoadedRecentlyPlayed &&
            homeProvider.recentlyPlayed.isNotEmpty);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        30.column,
        if (homeProvider.isLoadingRecentlyPlayed)
          RecentlyPlayedSection(items: const [], isLoading: true)
        else if (homeProvider.hasLoadedRecentlyPlayed &&
            homeProvider.recentlyPlayed.isNotEmpty)
          RecentlyPlayedSection(
            items: homeProvider.recentlyPlayed,
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

        // Category tabs that drive the section directly below.
        CategoryTabsSection(
          categories: _categoryTabs,
          selectedCategoryId: _selectedCategoryId,
          onCategoryChanged: (categoryId) {
            setState(() => _selectedCategoryId = categoryId);
            context.read<HomeProvider>().loadCategoryTab(categoryId);
          },
        ),
        24.column,

        if (showCategorySection)
          FeaturedPlaylistSection(
            playlists: categoryCards,
            isLoading: categoryLoading,
            onPlaylistTap: _openCategoryPlaylist,
            onSeeAll: () {
              final uri = Uri(
                path: AppRouter.trending,
                queryParameters: {'tabId': _selectedCategoryId},
              );
              context.push(uri.toString());
            },
          ),
        if (showCategorySection) 20.column,

        // Curated featured playlists (always-on, below the category-driven cards).
        if (showFeaturedSection) ...[
          FeaturedPlaylistSection(
            playlists: featured,
            isLoading: featuredLoading,
            onPlaylistTap: _openCategoryPlaylist,
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

        SpotlightSection(
          tabs: _spotlightTabs,
          selectedTabId: _selectedSpotlightTabId,
          onTabChanged: (tabId) {
            setState(() => _selectedSpotlightTabId = tabId);
            context.read<HomeProvider>().loadSpotlightTab(tabId);
          },
          items: spotlightItems,
          isLoading: spotlightLoading,
          onItemTap: _openSpotlight,
          onUnlockTap: _openSpotlight,
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
      ],
    );
  }

  Widget _buildVideosContent(HomeProvider homeProvider) {
    final showTrendingArtistsSection =
        homeProvider.isLoadingTrendingArtists ||
            (homeProvider.hasLoadedTrendingArtists &&
                homeProvider.trendingArtists.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        19.column,
        Padding(
          padding: EdgeInsets.only(right: 24.padding),
          child: VideoTabsSection(
            selectedTabId: _selectedVideoTabId,
            onTabChanged: (tabId) {
              setState(() {
                _selectedVideoTabId = tabId;
              });
            },
          ),
        ),
        30.column,
        RecentlyPlayedVideosSection(items: _recentlyPlayedVideos),
        30.column,
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
            setState(() {
              _selectedCategoryId = categoryId;
            });
          },
        ),
        24.column,
        TrendingVideosSection(items: _trendingVideos),
        30.column,
        VideoPopularNewReleasesSection(items: _trendingVideos),
        30.column,
        VideoSpotlightSection(
          tabs: _spotlightTabs,
          selectedTabId: _selectedVideoSpotlightTabId,
          onTabChanged: (tabId) {
            setState(() {
              _selectedVideoSpotlightTabId = tabId;
            });
          },
          items: _videoSpotlightItems,
        ),
        30.column,
        VideoFollowedSection(
          title: 'From those you follow',
          items: _videoFollowedItems,
        ),
        100.column,
      ],
    );
  }

  Widget _buildDjMixContent(HomeProvider homeProvider) {
    return _buildMusicContent(homeProvider);
  }

  Widget _buildPodcastContent(HomeProvider homeProvider) {
    return _buildMusicContent(homeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final isPhoneLayout = MediaQuery.sizeOf(context).width < 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: isPhoneLayout ? const HomeMenuDrawer() : null,
      body: Stack(
        children: [
          Column(
            children: [
              HomeHeader(
                selectedTab: _selectedTab,
                toggleOptions: _toggleOptions,
                onTabChanged: (tab) {
                  setState(() => _selectedTab = tab);
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
          if (_currentTrack != null)
            NowPlayingBar(
              currentTrack: _currentTrack,
              onTap: () {
                final t = _currentTrack;
                if (t == null) return;
                _openPlayer(
                  trackId: t.id,
                  title: t.title,
                  artistName: t.artist,
                  coverUrl: t.albumArtUrl,
                  isUnlocked: t.isUnlocked,
                );
              },
              onPlayPauseTap: () {
                setState(() {
                  _currentTrack = _currentTrack?.copyWith(
                    isPlaying: !(_currentTrack?.isPlaying ?? false),
                  );
                });
              },
              onUnlockTap: () {},
            ),
        ],
      ),
    );
  }
}
