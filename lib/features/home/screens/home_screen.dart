import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/tab_option.dart';
import 'package:muxify/features/home/models/recently_played_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/models/track_item.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/playlist_item.dart';
import 'package:muxify/features/home/models/new_release_item.dart';
import 'package:muxify/features/home/models/spotlight_tab.dart';
import 'package:muxify/features/home/models/spotlight_item.dart';
import 'package:muxify/features/home/models/followed_item.dart';
import 'package:muxify/features/home/models/now_playing_item.dart';
import 'package:muxify/features/home/widgets/home_header.dart';
import 'package:muxify/features/home/widgets/recently_played_section.dart';
import 'package:muxify/features/home/widgets/trending_artists_section.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/features/home/widgets/featured_playlist_section.dart';
import 'package:muxify/features/home/widgets/popular_releases_section.dart';
import 'package:muxify/features/home/widgets/spotlight_section.dart';
import 'package:muxify/features/home/widgets/followed_section.dart';
import 'package:muxify/features/home/widgets/now_playing_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTab = 'Music';
  String _selectedCategoryId = 'trending';
  String _selectedSpotlightTabId = 'spotlight';

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

  // Recently played data - replace with backend data
  final List<RecentlyPlayedItem> _recentlyPlayed = [
    RecentlyPlayedItem(id: '1', title: '5ive', artist: 'Artist Name'),
    RecentlyPlayedItem(id: '2', title: 'Olamide', artist: 'Artist Name'),
    RecentlyPlayedItem(id: '3', title: 'Boy Alone', artist: 'Artist Name'),
    RecentlyPlayedItem(id: '4', title: 'Morayo', artist: 'Artist Name'),
    RecentlyPlayedItem(id: '5', title: 'New Album', artist: 'Artist Name'),
  ];

  // Trending artists data - replace with backend data
  final List<TrendingArtist> _trendingArtists = [
    TrendingArtist(id: '1', name: 'Davido', isVerified: true),
    TrendingArtist(id: '2', name: 'Burna Boy', isVerified: true),
    TrendingArtist(id: '3', name: 'Flavour', isVerified: true),
    TrendingArtist(id: '4', name: 'Rema', isVerified: true),
    TrendingArtist(id: '5', name: 'Omah Lay', isVerified: true),
    TrendingArtist(id: '6', name: 'Omah Lay', isVerified: true),
  ];

  // Featured playlists data - replace with backend data
  final List<PlaylistItem> _featuredPlaylists = [
    PlaylistItem(
      id: '1',
      title: 'Afrobeats',
      songCount: '54 songs',
      isFavorite: false,
      tracks: [
        TrackItem(id: '1', title: 'With You ft. Omah Lay', artist: 'Davido'),
        TrackItem(id: '2', title: 'Bad Girl', artist: 'Wizkid'),
        TrackItem(id: '3', title: 'Skelebu', artist: 'Rema'),
        TrackItem(id: '4', title: 'Bundle', artist: 'Burna Boy'),
        TrackItem(id: '5', title: 'On The', artist: 'Tiwa Sa'),
        TrackItem(id: '6', title: 'Street C', artist: 'Olamide'),
        TrackItem(id: '7', title: 'Dangba', artist: 'Bella Sh'),
        TrackItem(id: '8', title: 'Lost', artist: 'Fola'),
      ],
    ),
    PlaylistItem(
      id: '1',
      title: 'Afrobeats',
      songCount: '54 songs',
      isFavorite: false,
      tracks: [
        TrackItem(id: '1', title: 'With You ft. Omah Lay', artist: 'Davido'),
        TrackItem(id: '2', title: 'Bad Girl', artist: 'Wizkid'),
        TrackItem(id: '3', title: 'Skelebu', artist: 'Rema'),
        TrackItem(id: '4', title: 'Bundle', artist: 'Burna Boy'),
        TrackItem(id: '5', title: 'On The', artist: 'Tiwa Sa'),
        TrackItem(id: '6', title: 'Street C', artist: 'Olamide'),
        TrackItem(id: '7', title: 'Dangba', artist: 'Bella Sh'),
        TrackItem(id: '8', title: 'Lost', artist: 'Fola'),
      ],
    ),
    PlaylistItem(
      id: '1',
      title: 'Afrobeats',
      songCount: '54 songs',
      isFavorite: false,
      tracks: [
        TrackItem(id: '1', title: 'With You ft. Omah Lay', artist: 'Davido'),
        TrackItem(id: '2', title: 'Bad Girl', artist: 'Wizkid'),
        TrackItem(id: '3', title: 'Skelebu', artist: 'Rema'),
        TrackItem(id: '4', title: 'Bundle', artist: 'Burna Boy'),
        TrackItem(id: '5', title: 'On The', artist: 'Tiwa Sa'),
        TrackItem(id: '6', title: 'Street C', artist: 'Olamide'),
        TrackItem(id: '7', title: 'Dangba', artist: 'Bella Sh'),
        TrackItem(id: '8', title: 'Lost', artist: 'Fola'),
      ],
    ),
  ];

  // Popular new releases data - replace with backend data
  final List<NewReleaseItem> _popularReleases = [
    NewReleaseItem(id: '1', albumName: 'Laho', artistName: 'Shallipopi'),
    NewReleaseItem(id: '2', albumName: 'One Condition', artistName: 'DJ Tunez'),
    NewReleaseItem(id: '3', albumName: 'I Told Them', artistName: 'Young John'),
  ];

  // Spotlight tabs data
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

  // Spotlight items data - replace with backend data
  final List<SpotlightItem> _spotlightItems = [
    SpotlightItem(
      id: '1',
      title: 'I Told Them',
      artist: 'Burna Boy',
      playCount: '23,210,000 Plays',
      isUnlocked: false,
    ),
  ];

  // Followed items data - replace with backend data
  final List<FollowedItem> _followedItems = [
    FollowedItem(id: '1', title: 'In His Will', artist: 'Mercy Chinwo'),
    FollowedItem(id: '2', title: 'Lovin\'', artist: 'Simi'),
    FollowedItem(id: '3', title: 'Desire', artist: 'Uriel'),
    FollowedItem(id: '4', title: 'Twice As Tall', artist: 'Burna Boy'),
    FollowedItem(id: '5', title: 'I Told Them', artist: 'Burna Boy'),
    FollowedItem(id: '6', title: 'Fall', artist: 'Davido'),
    FollowedItem(id: '7', title: 'Impersonation', artist: 'Davido ft. Jeage'),
    FollowedItem(id: '8', title: 'Dada', artist: 'Young John'),
  ];

  // Currently playing track - replace with backend data
  NowPlayingItem? _currentTrack = NowPlayingItem(
    id: '1',
    title: 'Boy Alone',
    artist: 'Omah Lay',
    isPlaying: true,
    isUnlocked: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              HomeHeader(
                selectedTab: _selectedTab,
                toggleOptions: _toggleOptions,
                onTabChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 24.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.column,
                      RecentlyPlayedSection(items: _recentlyPlayed),
                      30.column,
                      TrendingArtistsSection(artists: _trendingArtists),
                      30.column,
                      // Category Tabs Section
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
                      // Featured Playlist Section
                      FeaturedPlaylistSection(playlists: _featuredPlaylists),
                      30.column,
                      // Popular New Releases Section
                      PopularReleasesSection(
                        title: 'Popular New Releases',
                        releases: _popularReleases,
                      ),
                      32.column,
                      // Spotlight Section
                      SpotlightSection(
                        tabs: _spotlightTabs,
                        selectedTabId: _selectedSpotlightTabId,
                        onTabChanged: (tabId) {
                          setState(() {
                            _selectedSpotlightTabId = tabId;
                          });
                        },
                        items: _spotlightItems,
                      ),
                      32.column,
                      // From Those You Follow Section
                      FollowedSection(
                        title: 'From those you follow',
                        items: _followedItems,
                      ),
                      32.column,
                      // Other sections will go here
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Now Playing Bar - Fixed at bottom
          NowPlayingBar(
            currentTrack: _currentTrack,
            onTap: () {
              // TODO: Navigate to full player screen
            },
            onPlayPauseTap: () {
              setState(() {
                _currentTrack = _currentTrack?.copyWith(
                  isPlaying: !(_currentTrack?.isPlaying ?? false),
                );
              });
            },
            onUnlockTap: () {
              // TODO: Handle unlock action
            },
          ),
        ],
      ),
    );
  }
}
