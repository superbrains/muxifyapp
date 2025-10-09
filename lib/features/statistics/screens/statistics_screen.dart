import 'dart:math';

import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/statistics/models/gift_statistics_item.dart';
import 'package:muxify/features/statistics/models/top_giver_item.dart';
import 'package:muxify/features/statistics/models/most_given_item.dart';
import 'package:muxify/features/statistics/widgets/gift_statistics_item.dart';
import 'package:muxify/features/statistics/widgets/top_giver_item_widget.dart';
import 'package:muxify/features/statistics/widgets/most_given_item_widget.dart';
import 'package:muxify/shared/widgets/content_header.dart';
import 'package:muxify/shared/widgets/gradient_header_with_tabs.dart';
import 'package:muxify/features/home/models/category_tab.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedTab = 'most_gifted';
  String _selectedMediaType = 'Music';

  // Badge images
  static const List<String> _badgeImages = [
    'assets/pngs/badge_1.png',
    'assets/pngs/badge_2.png',
    'assets/pngs/badge_3.png',
    'assets/pngs/badge_4.png',
  ];

  // Helper method to generate random badges
  static List<UserBadge> _generateRandomBadges() {
    final random = Random();
    final badges = <UserBadge>[];

    // Generate 4 random badges
    for (int i = 0; i < 4; i++) {
      badges.add(
        UserBadge(
          id: i.toString(),
          imageUrl: _badgeImages[random.nextInt(_badgeImages.length)],
        ),
      );
    }

    return badges;
  }

  final List<CategoryTab> _tabs = [
    CategoryTab(
      id: 'most_gifted',
      title: 'Most Gifted',
      icon: Icons.card_giftcard,
    ),
    CategoryTab(id: 'top_giver', title: 'Top Giver', icon: Icons.emoji_events),
    CategoryTab(id: 'most_given', title: 'Most Given', icon: Icons.favorite),
  ];

  // Sample data - replace with backend data
  final List<GiftStatisticsItem> _mostGiftedItems = [
    GiftStatisticsItem(
      id: '1',
      title: 'With You ft. Omah Lay',
      artist: 'Davido',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '2',
      title: 'Bad Girl',
      artist: 'Wizkid',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '3',
      title: 'Skelebu',
      artist: 'Rema',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '4',
      title: 'Bundle',
      artist: 'Burna Boy',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '5',
      title: 'Lost',
      artist: 'Fola',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '1',
      title: 'With You ft. Omah Lay',
      artist: 'Davido',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '2',
      title: 'Bad Girl',
      artist: 'Wizkid',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '3',
      title: 'Skelebu',
      artist: 'Rema',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '4',
      title: 'Bundle',
      artist: 'Burna Boy',
      giftCount: '156,000',
    ),
    GiftStatisticsItem(
      id: '5',
      title: 'Lost',
      artist: 'Fola',
      giftCount: '156,000',
    ),
  ];

  // Top Givers data - replace with backend data
  final List<TopGiverItem> _topGiversItems = [
    TopGiverItem(
      id: '1',
      username: 'big_josh',
      avatarUrl: 'assets/pngs/profile_placeholder.png',
      avatarBackgroundColor: '#E1BEE7', // Light purple
      badges: _generateRandomBadges(),
      associatedArtists: 'Davido, Wizkid, Fola, M...',
      giftWorth: '156,000',
    ),
    TopGiverItem(
      id: '2',
      username: 'aku_baby',
      avatarUrl: 'assets/pngs/profile_placeholder.png',
      avatarBackgroundColor: '#E1BEE7', // Light purple
      badges: _generateRandomBadges(),
      associatedArtists: 'Burna Boy, Tiwa Savage, O...',
      giftWorth: '156,000',
    ),
    TopGiverItem(
      id: '3',
      username: 'moving_man',
      avatarUrl: 'assets/pngs/profile_placeholder.png',
      avatarBackgroundColor: '#FFCDD2', // Dark red
      badges: _generateRandomBadges(),
      associatedArtists: 'Rema, Bella Shmurda, A...',
      giftWorth: '156,000',
    ),
    TopGiverItem(
      id: '4',
      username: 'webby_girl',
      avatarUrl: 'assets/pngs/profile_placeholder.png',
      avatarBackgroundColor: '#E1BEE7', // Light purple
      badges: _generateRandomBadges(),
      associatedArtists: 'Omah Lay, Simi, Uriel...',
      giftWorth: '156,000',
    ),
    TopGiverItem(
      id: '5',
      username: 'sean_nero',
      avatarUrl: 'assets/pngs/profile_placeholder.png',
      avatarBackgroundColor: '#BBDEFB', // Light blue
      badges: _generateRandomBadges(),
      associatedArtists: 'Young John, Mercy Chin...',
      giftWorth: '156,000',
    ),
  ];

  // Most Given data - replace with backend data
  final List<MostGivenItem> _mostGivenItems = [
    MostGivenItem(
      id: '1',
      artistName: 'Davido',
      workSnippet: '5ive, With You, Skelew...',
      receivedGifts: '156,000',
      rank: 1,
    ),
    MostGivenItem(
      id: '2',
      artistName: 'Olamide',
      workSnippet: 'Olamidė, Street ot, Sak...',
      receivedGifts: '156,000',
      rank: 2,
    ),
    MostGivenItem(
      id: '3',
      artistName: 'Rema',
      workSnippet: 'Ozeba, Dumebi, Train...',
      receivedGifts: '156,000',
      rank: 3,
    ),
    MostGivenItem(
      id: '4',
      artistName: 'Peruzzi',
      workSnippet: 'Ijeoma, Benita, Higher Enjoymen...',
      receivedGifts: '156,000',
      rank: 4,
    ),
    MostGivenItem(
      id: '5',
      artistName: 'Burna Boy',
      workSnippet: 'No Weakness, I Told Them...',
      receivedGifts: '156,000',
      rank: 5,
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
            title: 'Statistics',
            gradientColor: AppColors.statisticsHeaderGradient,
            selectedMediaType: _selectedMediaType,
            onMediaTypeChanged: (mediaType) {
              setState(() {
                _selectedMediaType = mediaType;
              });
              // TODO: Filter statistics by media type
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
          // 16.column,
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 27.padding),
              child: _buildStatisticsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsList() {
    switch (_selectedTab) {
      case 'most_gifted':
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mostGiftedItems.length,
          padding: EdgeInsets.only(top: 35.padding),
          separatorBuilder: (context, index) => 25.column,
          itemBuilder: (context, index) {
            return GiftStatisticsItemWidget(
              item: _mostGiftedItems[index],
              onTap: () {},
            );
          },
        );
      case 'top_giver':
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topGiversItems.length,
          padding: EdgeInsets.only(top: 35.padding),
          separatorBuilder: (context, index) => 25.column,
          itemBuilder: (context, index) {
            return TopGiverItemWidget(
              item: _topGiversItems[index],
              onTap: () {},
            );
          },
        );
      case 'most_given':
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mostGivenItems.length,
          padding: EdgeInsets.only(top: 35.padding),
          separatorBuilder: (context, index) => 25.column,
          itemBuilder: (context, index) {
            return MostGivenItemWidget(
              item: _mostGivenItems[index],
              onTap: () {},
            );
          },
        );
      default:
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mostGiftedItems.length,
          padding: EdgeInsets.only(top: 35.padding),
          separatorBuilder: (context, index) => 25.column,
          itemBuilder: (context, index) {
            return GiftStatisticsItemWidget(
              item: _mostGiftedItems[index],
              onTap: () {},
            );
          },
        );
    }
  }

  String _getSectionTitle() {
    switch (_selectedTab) {
      case 'most_gifted':
        return 'Most Gifted';
      case 'top_giver':
        return 'Top Giver';
      case 'most_given':
        return 'Highest Given';
      default:
        return 'Statistics';
    }
  }
}
