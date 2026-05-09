import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/my_music/providers/library_provider.dart';
import 'package:muxify/features/my_music/screens/playlists_tab.dart';
import 'package:muxify/features/my_music/screens/unlocked_tab.dart';

/// Two-tab hub: "Unlocked" (the user's library) and "Playlists" (local mixes).
/// Single entry point at `/my-music` reached from the Home header icon and the
/// Fan Profile drawer.
class MyMusicScreen extends StatefulWidget {
  const MyMusicScreen({super.key});

  @override
  State<MyMusicScreen> createState() => _MyMusicScreenState();
}

class _MyMusicScreenState extends State<MyMusicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) HapticFeedback.selectionClick();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LibraryProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Brand gradient header — same red→black wash as the now-playing
          // screen so the hub feels like a sibling of the player.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.headerGradient.withValues(alpha: 0.6),
                    AppColors.headerGradient.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                10.column,
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: const [
                      UnlockedTab(),
                      PlaylistsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding, vertical: 8.padding),
      child: Row(
        children: [
          _RoundIcon(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          14.row,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Music',
                  style: AppTextStyles.heading2.copyWith(
                    fontFamily: 'Luckiest Guy',
                    fontSize: 28.font,
                    height: 1.0,
                  ),
                ),
                4.column,
                Text(
                  'Everything you own, plus the mixes you build.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.font,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Container(
        height: 52.maxHeight,
        decoration: BoxDecoration(
          color: AppColors.glassyDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(28.radius),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.06),
          ),
        ),
        child: TabBar(
          controller: _tabs,
          indicator: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(24.radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(4.padding),
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelColor: AppColors.text,
          unselectedLabelColor: AppColors.text.withValues(alpha: 0.55),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.font,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.font,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Unlocked'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 40.maxHeight,
        width: 40.maxWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassyLight.withValues(alpha: 0.6),
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, size: 18.icon, color: AppColors.text),
      ),
    );
  }
}
