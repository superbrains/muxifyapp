import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/features/home/data/feed_dtos.dart';
import 'package:muxify/features/home/data/music_feed_repository.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/shared/widgets/content_header.dart';
import 'package:muxify/shared/widgets/genre_song_item_widget.dart';
import 'package:muxify/shared/widgets/gradient_header_with_tabs.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:provider/provider.dart';

class FeaturedPlaylistScreen extends StatefulWidget {
  final String? initialTabId;

  const FeaturedPlaylistScreen({super.key, this.initialTabId});

  @override
  State<FeaturedPlaylistScreen> createState() => _FeaturedPlaylistScreenState();
}

class _FeaturedPlaylistScreenState extends State<FeaturedPlaylistScreen> {
  late String _selectedTab;
  String _selectedMediaType = 'Music';

  final MusicFeedRepository _feed = MusicFeedRepository();

  // Per-tab cache so flipping tabs is instant after first load.
  final Map<String, List<GenreSongItem>> _songsByTab = {};
  final Set<String> _loading = {};
  Object? _error;

  final List<CategoryTab> _tabs = [
    CategoryTab(id: 'trending', title: 'Trending', icon: Icons.trending_up),
    CategoryTab(
      id: 'hot_release',
      title: 'Hot Release',
      icon: Icons.local_fire_department,
    ),
    CategoryTab(id: 'top_chart', title: 'Top Chart', icon: Icons.bar_chart),
    CategoryTab(id: 'new_release', title: 'New Release', icon: Icons.fiber_new),
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabId;
    _selectedTab =
        (initial != null && _tabs.any((t) => t.id == initial)) ? initial : 'trending';
    _loadTab(_selectedTab);
  }

  Future<void> _loadTab(String tabId) async {
    if (_loading.contains(tabId)) return;
    if (_songsByTab.containsKey(tabId)) return;

    setState(() {
      _loading.add(tabId);
      _error = null;
    });

    try {
      final dtos = await _fetchForTab(tabId);
      if (!mounted) return;
      _songsByTab[tabId] = dtos
          .map(
            (t) => GenreSongItem(
              id: t.id,
              title: t.title,
              artist: t.artistName,
              albumArtUrl: t.coverArtUrl ?? '',
              isUnlocked: t.isUnlocked,
            ),
          )
          .toList(growable: false);
    } catch (e) {
      if (!mounted) return;
      _error = e;
      _songsByTab[tabId] = const [];
    } finally {
      if (mounted) {
        setState(() {
          _loading.remove(tabId);
        });
      }
    }
  }

  Future<List<FeedTrackDto>> _fetchForTab(String tabId) {
    switch (tabId) {
      case 'trending':
        return _feed.getTrendingTracks(period: 'week', pageSize: 30);
      case 'hot_release':
        return _feed.getHotReleases(days: 14, pageSize: 30);
      case 'top_chart':
        return _feed.getTopCharts(period: 'all', pageSize: 30);
      case 'new_release':
        return _feed.getNewReleases(days: 30, pageSize: 30);
      default:
        return _feed.getTrendingTracks(period: 'week', pageSize: 30);
    }
  }

  void _openPlayer(GenreSongItem song) {
    context.push(
      Uri(
        path: AppRouter.musicPlayer,
        queryParameters: {
          'trackId': song.id,
          'title': song.title,
          'artistName': song.artist,
          if (song.albumArtUrl.isNotEmpty) 'backgroundImageUrl': song.albumArtUrl,
          'isUnlocked': '${song.isUnlocked}',
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loading.contains(_selectedTab);
    final songs = _songsByTab[_selectedTab] ?? const [];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeaderWithTabs(
            gradientColor: AppColors.statisticsHeaderGradient,
            selectedMediaType: _selectedMediaType,
            onMediaTypeChanged: (mediaType) {
              setState(() => _selectedMediaType = mediaType);
            },
            onBackTap: () {
              Navigator.of(context).pop();
            },
            tabs: _tabs,
            selectedTabId: _selectedTab,
            onTabChanged: (categoryId) {
              setState(() => _selectedTab = categoryId);
              _loadTab(categoryId);
            },
          ),
          36.column,
          Padding(
            padding: EdgeInsets.only(
              left: 25.padding,
              right: 25.padding,
              bottom: 5.padding,
            ),
            child: ContentHeader(
              title: _getSectionTitle(),
              subtitle: _formattedToday(),
              filterText: 'Today, Latest',
              onFilterTap: () {},
            ),
          ),
          20.column,
          UnlockButton(
            width: 104.maxWidth,
            height: 42.buttonHeight,
            onTap: songs.isEmpty ? null : _showUnlockAllSongsModal,
            text: 'Play All',
            iconPath: 'assets/pngs/shuffle.png',
            backgroundColor: AppColors.toggleSelected,
            iconColor: AppColors.buttonColor,
            iconSize: 20.icon,
            spacing: 8.padding,
            padding: EdgeInsets.symmetric(
              horizontal: 9.padding,
              vertical: 10.padding,
            ),
            borderRadius: 25.radius,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _songsByTab.remove(_selectedTab);
                await _loadTab(_selectedTab);
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 27.padding),
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildBody(isLoading: isLoading, songs: songs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({required bool isLoading, required List<GenreSongItem> songs}) {
    if (isLoading && songs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.padding),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!isLoading && songs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.padding),
        child: Center(
          child: Text(
            _error == null ? 'Nothing here yet.' : 'Failed to load. Pull to retry.',
            style: TextStyle(color: AppColors.text.withValues(alpha: 0.6)),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      padding: EdgeInsets.only(top: 35.padding),
      separatorBuilder: (context, index) => 16.column,
      itemBuilder: (context, index) {
        final song = songs[index];
        return GenreSongItemWidget(
          item: song,
          onTap: () => _openPlayer(song),
          onPlayUnlockTap: () {
            if (song.isUnlocked ||
                context.read<UnlockedContentProvider>().isUnlocked(song.id)) {
              _openPlayer(song);
            } else {
              _showUnlockModal(song);
            }
          },
        );
      },
    );
  }

  String _getSectionTitle() {
    switch (_selectedTab) {
      case 'trending':
        return 'Trending';
      case 'hot_release':
        return 'Hot Release';
      case 'top_chart':
        return 'Top Chart';
      case 'new_release':
        return 'New Release';
      default:
        return 'Trending';
    }
  }

  String _formattedToday() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return 'Today, ${now.day} ${months[now.month - 1]}';
  }

  void _showUnlockAllSongsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () => Navigator.of(context).pop(),
          onUnlockPremium: () => Navigator.of(context).pop(),
          onUnlockFree: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showUnlockModal(GenreSongItem song) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () => Navigator.of(context).pop(),
          onUnlockPremium: () {
            Navigator.of(context).pop();
            _markSongUnlocked(song);
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            _markSongUnlocked(song);
          },
        );
      },
    );
  }

  void _markSongUnlocked(GenreSongItem song) {
    final list = _songsByTab[_selectedTab];
    if (list == null) return;
    final index = list.indexWhere((s) => s.id == song.id);
    if (index < 0) return;
    setState(() {
      _songsByTab[_selectedTab] = [
        ...list.take(index),
        list[index].copyWith(isUnlocked: true),
        ...list.skip(index + 1),
      ];
    });
  }
}
