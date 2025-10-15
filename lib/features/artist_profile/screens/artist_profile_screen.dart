import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/features/artist_profile/models/artist_profile.dart';
import 'package:muxify/features/artist_profile/widgets/albums_section_widget.dart';
import 'package:muxify/features/artist_profile/widgets/glass_button_widget.dart';
import 'package:muxify/features/artist_profile/widgets/latest_release_banner_widget.dart';
import 'package:muxify/features/artist_profile/widgets/navigation_buttons_widget.dart';
import 'package:muxify/features/artist_profile/widgets/play_button_widget.dart';
import 'package:muxify/features/artist_profile/widgets/songs_list_widget.dart';
import 'package:muxify/features/artist_profile/widgets/top_icons_widget.dart';
import 'package:muxify/features/featured_playlist/models/genre_song_item.dart';
import 'package:muxify/features/home/models/album_item.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/widgets/trending_artists_section.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  late ArtistProfile _artist;
  final List<AlbumItem> _albumItems = [
    AlbumItem(
      id: '1',
      title: 'African Giant',
      artist: 'Burna Boy',
      giftCount: '156,000',
      albumArtUrl: 'assets/pngs/follows.png',
    ),
    AlbumItem(
      id: '2',
      title: 'Twice As Tall',
      artist: 'Burna Boy',
      giftCount: '89,500',
      albumArtUrl: 'assets/pngs/follows.png',
    ),
    AlbumItem(
      id: '3',
      title: 'Love, Damini',
      artist: 'Burna Boy',
      giftCount: '234,200',
      albumArtUrl: 'assets/pngs/follows.png',
    ),
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
  final List<TrendingArtist> _trendingArtists = [
    TrendingArtist(id: '1', name: 'Davido', isVerified: true),
    TrendingArtist(id: '2', name: 'Burna Boy', isVerified: true),
    TrendingArtist(id: '3', name: 'Flavour', isVerified: true),
    TrendingArtist(id: '4', name: 'Rema', isVerified: true),
    TrendingArtist(id: '5', name: 'Omah Lay', isVerified: true),
    TrendingArtist(id: '6', name: 'Omah Lay', isVerified: true),
  ];

  @override
  void initState() {
    super.initState();
    // Sample data 
    _artist = ArtistProfile(
      id: '1',
      name: 'Burna Boy',
      coverImageUrl: 'assets/pngs/artist_profile.png',
      followers: "2,500,000",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // CustomScrollView for the main content
          CustomScrollView(
            slivers: [
              // Flexible app bar with the artist image
              SliverAppBar(
                expandedHeight: 400.maxHeight,
                pinned: false,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildArtistImageWithOverlay(),
                ),
              ),

              // Content below the image
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.1),
                        AppColors.background.withValues(alpha: 0.3),
                        AppColors.background.withValues(alpha: 0.6),
                        AppColors.background,
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.1, 0.2, 0.4, 0.6, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Content sections
                      _buildProfileContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top icons (fixed position)
          TopIconsWidget(
            onBackTap: () {
              Navigator.of(context).pop();
            },
            onSearchTap: () {
              // Open search
            },
            onMenuTap: () {
              // Open menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtistImageWithOverlay() {
    return Stack(
      children: [
        // Purple background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.artistProfilePurple,
                AppColors.artistProfilePurpleLight,
                AppColors.artistProfilePurpleDark,
                AppColors.artistProfilePurpleAccent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Artist image
        Positioned.fill(
          child: Image.asset(
            _artist.coverImageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),

        // Glass effect positioned closer to bottom of artist image
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200.maxHeight,
            decoration: BoxDecoration(
             
              boxShadow: [
                BoxShadow(
                  color: AppColors.background.withValues(alpha: 0.1),
                  spreadRadius: 20,
                  offset: Offset(0, 30),
                  blurStyle: BlurStyle.outer,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, 
                  AppColors.background.withValues(alpha: 0.1), 
                  AppColors.background.withValues(alpha: 0.4), 
                  AppColors.background.withValues(alpha: 0.6), 
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background, 
                ],
                stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Glass blur effect - more visible
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ), // More visible glass blur
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.2),
                              AppColors.background.withValues(alpha: 0.5),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Artist name and stats positioned on glass
                Positioned(
                  top: 20.padding,
                  left: 20.padding,
                  right: 20.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artist name with verification checkmark
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Text(
                            _artist.name,
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 35.font,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                         
                          Image.asset(
                            'assets/pngs/verify_green.png',
                            width: 25.icon,
                            height: 25.icon,
                          ),
                        ],
                      ),
                      8.column,
                      // Gift fans count
                      Text(
                        '${_artist.followers} Gift Fans',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16.font,
                          color: AppColors.text.withValues(alpha: 0.8),
                        ),
                      ),
                      20.column,
                      // Action buttons on glass
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassButtonWidget(text: 'Following', onTap: () {}),
                          GlassButtonWidget(
                            text: 'Gift Me',
                            onTap: () {},
                            showGiftIcon: true,
                          ),
                          PlayButtonWidget(
                            height: 53.maxHeight,
                            width: 53.maxWidth,
                            iconHeight: 17.icon,
                            iconWidth: 20.icon,
                            onTap: () {
                              // Play action
                            },
                            color: AppColors.buttonColor,
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 70.padding),
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Column(
        children: [
          // Content sections
          _buildContentSections(),
        ],
      ),
    );
  }


  Widget _buildContentSections() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation buttons (Music, Videos, Events, About)
          const NavigationButtonsWidget(),
          18.column,
          LatestReleaseBannerWidget(onTap: () {}),
          30.column,

          // Albums section
          SizedBox(
            height: 430.maxHeight, 
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2, // Only one albums section
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AlbumsSectionWidget(
                  albums: _albumItems,
                  onTap: () {},
                  onGiftCountTap: () {},
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 15.padding),
            ),
          ),
      
          41.column,
          Text(
            'Most Popular',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 18.font,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          15.column,
          SongsListWidget(
            songs: _genreSongs,
            onSongTap: (song) {},
            onPlayUnlockTap: (song) {
              setState(() {
                // Toggle play/unlock state
                final index = _genreSongs.indexOf(song);
                if (index != -1) {
                  _genreSongs[index] = _genreSongs[index].copyWith(
                    isUnlocked: !_genreSongs[index].isUnlocked,
                  );
                }
              });
            },
            onMenuTap: (song) {
              // Open menu
            },
          ),
          18.column,
          Center(
            child: Container(
              width: 104.maxWidth,
              height: 52.maxHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(25.radius),
              ),
              child: Text(
                'See All',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 18.font,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          47.column,
          TrendingArtistsSection(
            artists: _trendingArtists,
            title: 'Similar artists',
            showLeadingIcon: false,
          ),
        ],
      ),
    );
  }
}
