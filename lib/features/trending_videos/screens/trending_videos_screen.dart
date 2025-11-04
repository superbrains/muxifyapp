import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/widgets/grid_video_card.dart';
import 'package:muxify/shared/widgets/content_header.dart';
import 'package:muxify/shared/widgets/gradient_header_with_tabs.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:muxify/features/home/models/category_tab.dart';

class TrendingVideosScreen extends StatefulWidget {
  const TrendingVideosScreen({super.key});

  @override
  State<TrendingVideosScreen> createState() => _TrendingVideosScreenState();
}

class _TrendingVideosScreenState extends State<TrendingVideosScreen> {
  String _selectedTab = 'trending';
  String _selectedMediaType = 'Videos';

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

  // Sample video data
  final List<VideoItem> _videos = [
    VideoItem(
      id: '1',
      title: 'Oga Sabinus and Food',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
    ),
    VideoItem(
      id: '2',
      title: 'Food and Karate',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'KikiBoy',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
    ),
    VideoItem(
      id: '3',
      title: 'Billionaire Club ft. Olamide',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'MrNed',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
    ),
    VideoItem(
      id: '4',
      title: 'My crazy chef',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'MrRebel',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
    ),
    VideoItem(
      id: '5',
      title: 'Oga Sabinus and Food',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'Mr Funny',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
    ),
    VideoItem(
      id: '6',
      title: 'Food and Karate',
      imageUrl: 'assets/pngs/sabinus.png',
      creator: 'KikiBoy',
      creatorImageUrl: 'assets/pngs/follows.png',
      views: '25K',
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
              _showUnlockAllVideosModal();
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
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 27.padding),
              child: _buildVideosGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 1.3.maxHeight,
      ),
      itemCount: _videos.length,
      padding: EdgeInsets.only(top: 35.padding, bottom: 30.padding),
      itemBuilder: (context, index) {
        return GridVideoCard(
          item: _videos[index],
          onTap: () {
            // Navigate to video player via GoRouter
            context.push(AppRouter.videoPlayer);
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

  void _showUnlockAllVideosModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UnlockAllSongsModal(
          onClose: () {
            Navigator.of(context).pop();
          },
          onUnlockPremium: () {
            Navigator.of(context).pop();
            // Handle premium unlock
          },
          onUnlockFree: () {
            Navigator.of(context).pop();
            // Handle free unlock
          },
        );
      },
    );
  }
}
