import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/shared/widgets/genre_song_item_widget.dart';
import 'package:muxify/shared/widgets/content_header.dart';
import 'package:muxify/shared/widgets/gradient_header_with_tabs.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:muxify/features/home/models/category_tab.dart';

class FeaturedPlaylistScreen extends StatefulWidget {
  const FeaturedPlaylistScreen({super.key});

  @override
  State<FeaturedPlaylistScreen> createState() => _FeaturedPlaylistScreenState();
}

class _FeaturedPlaylistScreenState extends State<FeaturedPlaylistScreen> {
  String _selectedTab = 'trending';
  String _selectedMediaType = 'Music';

  // Navigation tabs
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

  // Sample data 
  final List<GenreSongItem> _genreSongs = [
    GenreSongItem(
      id: '1',
      title: 'With You ft. Omah Lay',
      artist: 'Davido',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '2',
      title: 'Bad Girl',
      artist: 'Wizkid',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
    GenreSongItem(
      id: '3',
      title: 'Skelebu',
      artist: 'Rema',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '4',
      title: 'Bundle',
      artist: 'Burna Boy',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: '5',
      title: 'Lost',
      artist: 'Fola',
      albumArtUrl: 'assets/pngs/follows.png',
      isUnlocked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Navigation Tabs
          GradientHeaderWithTabs(
            // title: 'Featured Playlist',
            gradientColor: AppColors.statisticsHeaderGradient,
            selectedMediaType: _selectedMediaType,
            onMediaTypeChanged: (mediaType) {
              setState(() {
                _selectedMediaType = mediaType;
              });
            },
            onBackTap: () {
              Navigator.of(context).pop();
            },
            tabs: _tabs,
            selectedTabId: _selectedTab,
            onTabChanged: (categoryId) {
              setState(() {
                _selectedTab = categoryId;
              });
            },
          ),
          36.column,
          // Content Header (Fixed)
          Padding(
            padding: EdgeInsets.only(
              left: 25.padding,
              right: 25.padding,
              bottom: 5.padding,
            ),
            child: ContentHeader(
              title: _getSectionTitle(),
              subtitle: 'Today, 3 September',
              filterText: 'Today, Latest',
              onFilterTap: () {},
            ),
          ),
          20.column,
          UnlockButton(
            width: 104.maxWidth,
            height: 42.buttonHeight,
            onTap: () {
              _showUnlockAllSongsModal();
            },
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
          // 30.column,
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 27.padding),
              child: _buildSongsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _genreSongs.length,
      padding: EdgeInsets.only(top: 35.padding),
      separatorBuilder: (context, index) => 16.column,
      itemBuilder: (context, index) {
        return GenreSongItemWidget(
          item: _genreSongs[index],
          onTap: () {},
          onPlayUnlockTap: () {
            setState(() {
              // Toggle play/unlock state
              _genreSongs[index] = _genreSongs[index].copyWith(
                isUnlocked: !_genreSongs[index].isUnlocked,
              );
            });
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

  void _showUnlockAllSongsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () {
          },
          onUnlockPremium: () {
           
          },
          onUnlockFree: () {
          },
        );
      },
    );
  }
}
