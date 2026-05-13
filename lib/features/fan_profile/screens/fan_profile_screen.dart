import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/fan_profile/widgets/fan_profile_app_bar.dart';
import 'package:muxify/features/fan_profile/widgets/fan_profile_section.dart';
import 'package:muxify/features/fan_profile/widgets/position_section.dart';
import 'package:muxify/features/fan_profile/widgets/artists_creators_section.dart';
import 'package:muxify/features/fan_profile/widgets/following_section.dart';
import 'package:muxify/features/fan_profile/widgets/medals_section.dart';
import 'package:muxify/features/fan_profile/widgets/badges_section.dart';
import 'package:muxify/features/fan_profile/widgets/activities_section.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';

class FanProfileScreen extends StatefulWidget {
  const FanProfileScreen({super.key});

  @override
  State<FanProfileScreen> createState() => _FanProfileScreenState();
}

class _FanProfileScreenState extends State<FanProfileScreen> {
  String _selectedTab = 'status';

  // Fan profile specific tabs
  final List<CategoryTab> _fanProfileTabs = [
    CategoryTab(id: 'status', title: 'Status', icon: Icons.flash_on),
    CategoryTab(
      id: 'achievement',
      title: 'Achievement',
      icon: Icons.emoji_events,
    ),
    CategoryTab(id: 'activities', title: 'Activities', icon: Icons.timeline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top Gradient (same as home screen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  transform: const GradientRotation(1.5),
                  colors: [
                    AppColors.headerGradient.withValues(alpha: 0.3),
                    AppColors.headerGradient.withValues(alpha: 0.5),
                    AppColors.headerGradient.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.9],
                ),
              ),
            ),
          ),

          // Bottom Gradient (different color)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  transform: const GradientRotation(-1.5),
                  colors: [
                    AppColors.statisticsHeaderGradient.withValues(alpha: 0.3),
                    AppColors.statisticsHeaderGradient.withValues(alpha: 0.5),
                    AppColors.statisticsHeaderGradient.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.9],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                const FanProfileHeader(),

                // Fixed Profile Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      27.column,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FanProfileSection(
                            username: 'big_josh',
                            profileImagePath:
                                'assets/pngs/fan_profile_image.png',
                            verifyBadgePath: 'assets/pngs/fan_verify.png',
                          ),
                          40.row,
                          GlassButtonWidget(
                            height: 40.maxHeight,
                            width: 100.maxWidth,
                            text: 'Gift Me',
                            onTap: () {},
                            showGiftIcon: true,
                          ),
                        ],
                      ),
                      15.column,
                      SizedBox(
                        width: 298.maxWidth,
                        child: Text(
                          textAlign: TextAlign.center,
                          "I'm a super Davido fan. Been streaming since day one — gifts, unlocks, all the way.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.text,
                            fontSize: 12.font,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      4.column,
                      Text(
                        textAlign: TextAlign.center,
                        'Joined Sept. 2025',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.text,
                          fontSize: 12.font,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      15.column,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12.padding,
                        children: [
                          Image.asset(
                            'assets/pngs/badge_1.png',
                            width: 33.icon,
                            height: 33.icon,
                          ),
                          Image.asset(
                            'assets/pngs/badge_2.png',
                            width: 33.icon,
                            height: 33.icon,
                          ),
                          Image.asset(
                            'assets/pngs/badge_3.png',
                            width: 33.icon,
                            height: 33.icon,
                          ),
                          Image.asset(
                            'assets/pngs/badge_4.png',
                            width: 33.icon,
                            height: 33.icon,
                          ),
                        ],
                      ),
                      15.column,
                    ],
                  ),
                ),

                // Category Tabs Section (Fixed)
                CategoryTabsSection(
                  height: 48.maxHeight,
                  paddingHorizontal: 16.padding,
                  categories: _fanProfileTabs,
                  selectedCategoryId: _selectedTab,
                  onCategoryChanged: (categoryId) {
                    setState(() {
                      _selectedTab = categoryId;
                    });
                  },
                ),

                // Scrollable Tab Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 25.padding),
                    child: Column(
                      children: [
                        21.column,
                        if (_selectedTab == 'status') ...[
                          const PositionSection(),
                          15.column,
                          const ArtistsCreatorsSection(),
                          15.column,
                          const FollowingSection(),
                        ],
                        if (_selectedTab == 'achievement') ...[
                          const MedalsSection(),
                          15.column,
                          const BadgesSection(),
                          30.column,
                        ],
                        if (_selectedTab == 'activities') ...[
                          const ActivitiesSection(),
                        ],
                        20.column,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
