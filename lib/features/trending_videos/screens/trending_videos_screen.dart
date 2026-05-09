import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/models/video_item.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/home/widgets/grid_video_card.dart';
import 'package:muxify/shared/widgets/content_header.dart';
import 'package:muxify/shared/widgets/gradient_header_with_tabs.dart';
import 'package:muxify/shared/widgets/unlock_all_songs_modal.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().loadVideoCategoryTab(_selectedTab);
    });
  }

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
              context.read<HomeProvider>().loadVideoCategoryTab(categoryId);
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
              child: Consumer<HomeProvider>(
                builder: (context, provider, _) {
                  final videos = provider.videosForCategory(_selectedTab);
                  final isLoading = provider.isLoadingVideoCategory(_selectedTab);
                  final hasLoaded = provider.hasLoadedVideoCategory(_selectedTab);
                  return _buildVideosGrid(
                    videos: videos,
                    isLoading: isLoading,
                    hasLoaded: hasLoaded,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosGrid({
    required List<VideoItem> videos,
    required bool isLoading,
    required bool hasLoaded,
  }) {
    if (isLoading && videos.isEmpty) {
      return _buildShimmerGrid();
    }
    if (videos.isEmpty && hasLoaded) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.padding),
        child: Center(
          child: Text(
            'No videos yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.font,
              color: AppColors.text.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 1.3.maxHeight,
      ),
      itemCount: videos.length,
      padding: EdgeInsets.only(top: 35.padding, bottom: 30.padding),
      itemBuilder: (context, index) {
        final item = videos[index];
        return GridVideoCard(
          item: item,
          onTap: () => _openVideoItem(item),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.padding,
        mainAxisSpacing: 20.padding,
        childAspectRatio: 1.3.maxHeight,
      ),
      itemCount: 4,
      padding: EdgeInsets.only(top: 35.padding, bottom: 30.padding),
      itemBuilder: (context, _) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF3A3A3A),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.radius),
            ),
          ),
        );
      },
    );
  }

  void _openVideoItem(VideoItem item) {
    final id = item.id.trim();
    if (id.isEmpty) return;
    final thumb = item.imageUrl.trim();
    final artistId = item.creatorId?.trim();
    final uri = Uri(
      path: AppRouter.videoPlayer,
      queryParameters: {
        'videoId': id,
        'title': item.title,
        'artistName': item.creator,
        if (artistId != null && artistId.isNotEmpty) 'artistId': artistId,
        if (thumb.isNotEmpty) 'thumbnailUrl': thumb,
        'isUnlocked': '${item.isUnlocked}',
      },
    );
    context.push(uri.toString());
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
