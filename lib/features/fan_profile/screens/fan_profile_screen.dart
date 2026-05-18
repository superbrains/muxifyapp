import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/fan_profile/data/fan_profile_repository.dart';
import 'package:muxify/features/fan_profile/models/fan_profile_models.dart';
import 'package:muxify/features/fan_profile/widgets/activities_section.dart';
import 'package:muxify/features/fan_profile/widgets/artists_creators_section.dart';
import 'package:muxify/features/fan_profile/widgets/badges_section.dart';
import 'package:muxify/features/fan_profile/widgets/fan_profile_app_bar.dart';
import 'package:muxify/features/fan_profile/widgets/fan_profile_section.dart';
import 'package:muxify/features/fan_profile/widgets/following_section.dart';
import 'package:muxify/features/fan_profile/widgets/gift_me_modal.dart';
import 'package:muxify/features/fan_profile/widgets/medals_section.dart';
import 'package:muxify/features/fan_profile/widgets/position_section.dart';
import 'package:muxify/features/home/models/category_tab.dart';
import 'package:muxify/features/home/widgets/category_tabs_section.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';

class FanProfileScreen extends StatefulWidget {
  const FanProfileScreen({super.key, required this.fanId});

  final String fanId;

  @override
  State<FanProfileScreen> createState() => _FanProfileScreenState();
}

class _FanProfileScreenState extends State<FanProfileScreen> {
  final FanProfileRepository _repository = FanProfileRepository();

  String _selectedTab = 'status';

  late Future<FanPublicProfile> _profileFuture;
  late Future<SupportedArtistsList> _supportedFuture;
  late Future<FollowedArtistsList> _followedFuture;
  Future<FanActivityList>? _activityFuture;
  Future<UserBadgeList>? _badgesFuture;
  Future<UserMedalList>? _medalsFuture;

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
  void initState() {
    super.initState();
    _kickoffStatusFutures();
  }

  void _kickoffStatusFutures() {
    _profileFuture = _repository.getFanProfile(widget.fanId);
    _supportedFuture = _repository.getSupportedArtists(widget.fanId);
    _followedFuture = _repository.getFollowedArtists(widget.fanId);
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      if (tab == 'achievement') {
        _badgesFuture ??= _repository.getFanBadges(widget.fanId);
        _medalsFuture ??= _repository.getFanMedals(widget.fanId);
      } else if (tab == 'activities') {
        _activityFuture ??= _repository.getFanActivity(widget.fanId);
      }
    });
  }

  Future<void> _onGiftTap(FanPublicProfile profile) async {
    final username = profile.username ?? profile.displayName ?? 'this fan';
    await GiftMeModal.show(
      context,
      recipientFanId: profile.id,
      recipientUsername: username,
    );
  }

  void _openArtistProfile({
    required String artistId,
    required String artistName,
    String? avatarUrl,
  }) {
    if (artistId.trim().isEmpty) return;
    final queryParameters = <String, String>{
      'artistId': artistId.trim(),
      'artistName': artistName.trim().isEmpty ? 'Artist' : artistName.trim(),
      'isFollowing': 'true',
      'isVerified': 'true',
      if ((avatarUrl ?? '').trim().isNotEmpty)
        'coverImageUrl': avatarUrl!.trim(),
    };
    final uri = Uri(
      path: AppRouter.artistProfile,
      queryParameters: queryParameters,
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top gradient
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
          // Bottom gradient
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
          SafeArea(
            child: FutureBuilder<FanPublicProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Column(
                    children: const [
                      FanProfileHeader(),
                      Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Column(
                    children: [
                      const FanProfileHeader(),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.padding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.text,
                                  size: 32.icon,
                                ),
                                10.column,
                                Text(
                                  'Could not load this profile.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                                if (snapshot.error != null) ...[
                                  6.column,
                                  Text(
                                    '${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          AppColors.text.withValues(alpha: 0.6),
                                      fontSize: 12.font,
                                    ),
                                  ),
                                ],
                                12.column,
                                FilledButton(
                                  onPressed: () {
                                    setState(_kickoffStatusFutures);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return _buildLoadedBody(context, snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, FanPublicProfile profile) {
    final username = profile.username ?? profile.displayName ?? 'Unknown';
    final bio = (profile.bio == null || profile.bio!.trim().isEmpty)
        ? 'Music fan on Muxify.'
        : profile.bio!.trim();
    final joinedLabel = _formatJoinedLabel(profile.joinedAt);

    return Column(
      children: [
        const FanProfileHeader(),
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
                    username: username,
                    fallbackProfileImagePath:
                        'assets/pngs/fan_profile_image.png',
                    verifyBadgePath: 'assets/pngs/fan_verify.png',
                    avatarUrl: profile.avatarUrl,
                    showVerifyBadge: profile.isVerified,
                  ),
                  40.row,
                  GlassButtonWidget(
                    height: 40.maxHeight,
                    width: 100.maxWidth,
                    text: 'Gift Me',
                    onTap: () => _onGiftTap(profile),
                    showGiftIcon: true,
                  ),
                ],
              ),
              15.column,
              SizedBox(
                width: 298.maxWidth,
                child: Text(
                  textAlign: TextAlign.center,
                  bio,
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
                joinedLabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  fontSize: 12.font,
                  fontWeight: FontWeight.w400,
                ),
              ),
              15.column,
              _buildFeaturedBadgeStrip(profile.featuredBadges),
              15.column,
            ],
          ),
        ),
        CategoryTabsSection(
          height: 48.maxHeight,
          paddingHorizontal: 16.padding,
          categories: _fanProfileTabs,
          selectedCategoryId: _selectedTab,
          onCategoryChanged: _onTabChanged,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25.padding),
            child: Column(
              children: [
                21.column,
                if (_selectedTab == 'status') ..._statusTab(profile),
                if (_selectedTab == 'achievement') ..._achievementTab(),
                if (_selectedTab == 'activities') ..._activitiesTab(),
                20.column,
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _statusTab(FanPublicProfile profile) {
    return [
      PositionSection(
        giftsRecord: profile.totalGiftValue,
        leaderboardRank: profile.leaderboardRank,
      ),
      15.column,
      FutureBuilder<SupportedArtistsList>(
        future: _supportedFuture,
        builder: (context, snapshot) {
          final list = snapshot.data?.artists ?? const <SupportedArtist>[];
          return ArtistsCreatorsSection(
            artists: list,
            onArtistTap: (artist) => _openArtistProfile(
              artistId: artist.artistId,
              artistName: artist.artistName ?? 'Artist',
              avatarUrl: artist.avatarUrl,
            ),
          );
        },
      ),
      15.column,
      FutureBuilder<FollowedArtistsList>(
        future: _followedFuture,
        builder: (context, snapshot) {
          final list = snapshot.data?.artists ?? const <FollowedArtist>[];
          return FollowingSection(
            artists: list,
            onArtistTap: (artist) => _openArtistProfile(
              artistId: artist.artistId,
              artistName: artist.artistName ?? 'Artist',
              avatarUrl: artist.avatarUrl,
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _achievementTab() {
    return [
      FutureBuilder<UserMedalList>(
        future: _medalsFuture,
        builder: (context, snapshot) {
          final list = snapshot.data?.medals ?? const <UserMedal>[];
          return MedalsSection(medals: list);
        },
      ),
      15.column,
      FutureBuilder<UserBadgeList>(
        future: _badgesFuture,
        builder: (context, snapshot) {
          final list = snapshot.data?.badges ?? const <UserBadge>[];
          return BadgesSection(badges: list);
        },
      ),
      30.column,
    ];
  }

  List<Widget> _activitiesTab() {
    return [
      FutureBuilder<FanActivityList>(
        future: _activityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 32.padding),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final list = snapshot.data?.activities ?? const <FanActivity>[];
          return ActivitiesSection(activities: list);
        },
      ),
    ];
  }

  Widget _buildFeaturedBadgeStrip(List<UserBadge> featuredBadges) {
    const fallbackAssets = <String>[
      'assets/pngs/badge_1.png',
      'assets/pngs/badge_2.png',
      'assets/pngs/badge_3.png',
      'assets/pngs/badge_4.png',
    ];

    // Always render four slots: real badge icon if available, else asset
    // fallback in the same position so the row keeps its established layout.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final fallback = fallbackAssets[index % fallbackAssets.length];
        final hasBadge = index < featuredBadges.length &&
            featuredBadges[index].icon.trim().isNotEmpty;
        final widget = hasBadge
            ? Image.network(
                featuredBadges[index].icon,
                width: 33.icon,
                height: 33.icon,
                errorBuilder: (_, __, ___) => Image.asset(
                  fallback,
                  width: 33.icon,
                  height: 33.icon,
                ),
              )
            : Image.asset(
                fallback,
                width: 33.icon,
                height: 33.icon,
              );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.padding),
          child: widget,
        );
      }),
    );
  }

  static const _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatJoinedLabel(DateTime when) {
    final local = when.toLocal();
    final month = _months[(local.month - 1).clamp(0, 11)];
    return 'Joined $month. ${local.year}';
  }
}
