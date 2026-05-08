import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/artist_profile/models/artist_profile.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/widgets/albums_section_widget.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';
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
  final TrendingArtist artist;
  final String? mediaType;

  const ArtistProfileScreen({super.key, required this.artist, this.mediaType});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  final NumberFormat _followerFormat = NumberFormat.decimalPattern();

  late ArtistProfile _artist;
  late bool _isFollowing;
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

  // Video-specific album items (Most Played)
  final List<AlbumItem> _videoAlbumItems = [
    AlbumItem(
      id: 'vollen1',
      title: 'Excuse me Miss',
      artist: 'Mr Funny',
      giftCount: '156,000',
      albumArtUrl: 'assets/pngs/artist_profile_video.png',
    ),
    AlbumItem(
      id: 'vollen2',
      title: 'But Why Sabinus',
      artist: 'Mr Funny',
      giftCount: '156,000',
      albumArtUrl: 'assets/pngs/video_spotlight.png',
    ),
    AlbumItem(
      id: 'vollen3',
      title: 'Pastor Sabinus',
      artist: 'Mr Funny',
      giftCount: '156,000',
      albumArtUrl: 'assets/pngs/sabinus.png',
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

  // Video-specific most popular items
  final List<GenreSongItem> _videoMostPopular = [
    GenreSongItem(
      id: 'v1',
      title: 'Sabinus no dey learn',
      artist: 'Mr Funny',
      albumArtUrl: 'assets/pngs/artist_profile_video.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: 'v2',
      title: 'Adventures of Sabinus',
      artist: 'Mr Funny',
      albumArtUrl: 'assets/pngs/video_spotlight.png',
      isUnlocked: true,
    ),
    GenreSongItem(
      id: 'v3',
      title: 'Soso',
      artist: 'Mr Funny',
      albumArtUrl: 'assets/pngs/sabinus.png',
      isUnlocked: false,
    ),
    GenreSongItem(
      id: 'v4',
      title: 'Never Forget',
      artist: 'Mr Funny',
      albumArtUrl: 'assets/pngs/kiki.png',
      isUnlocked: true,
    ),
    GenreSongItem(
      id: 'v5',
      title: 'Attention ft. Justin Bieber',
      artist: 'Mr Funny',
      albumArtUrl: 'assets/pngs/latest_release.png',
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

  // Video-specific similar creators
  final List<TrendingArtist> _videoSimilarCreators = [
    TrendingArtist(id: 'vc1', name: 'Funny Bros', isVerified: true),
    TrendingArtist(id: 'vc2', name: 'Cute Abiola', isVerified: true),
    TrendingArtist(id: 'vc3', name: 'Ghe Ghe', isVerified: true),
    TrendingArtist(id: 'vc4', name: 'Kiekie', isVerified: true),
    TrendingArtist(id: 'vc5', name: 'Mr Macaroni', isVerified: true),
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.artist;
    _isFollowing = a.isFollowing;
    final rawCover = a.imageUrl?.trim() ?? '';
    final cover = rawCover.isEmpty
        ? 'assets/pngs/artist_profile.png'
        : rawCover;
    _artist = ArtistProfile(
      id: a.id.isNotEmpty ? a.id : '1',
      name: a.name.isNotEmpty ? a.name : 'Artist',
      coverImageUrl: cover,
      followerCount: a.followerCount,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArtistProfileProvider>().loadGiftTypes();
    });
  }

  Future<void> _toggleFollow() async {
    final provider = context.read<ArtistProfileProvider>();
    if (provider.isActionInFlight) return;

    final id = _artist.id.trim();
    if (id.isEmpty) {
      await AppToast.showError('Missing artist.');
      return;
    }

    try {
      final r = _isFollowing
          ? await provider.unfollowArtist(id)
          : await provider.followArtist(id);

      if (!mounted || r == null) return;

      setState(() {
        _isFollowing = r.isFollowing;
        _artist = _artist.copyWith(followerCount: r.artistFollowerCount);
      });

      final msg = r.message?.trim();
      if (msg != null && msg.isNotEmpty) {
        await AppToast.showInfo(msg);
      }
    } catch (e) {
      await AppToast.showError(e.toString());
    }
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<ArtistProfileProvider>();
    await provider.loadGiftTypes();

    if (!mounted) return;
    final error = provider.giftsError?.trim();
    if (error != null && error.isNotEmpty) {
      await AppToast.showError(error);
    }
  }

  Widget _buildCoverImage(String urlOrPath) {
    final t = urlOrPath.trim();
    if (t.isEmpty) {
      return Image.asset(
        'assets/pngs/artist_profile.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      );
    }
    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: ApiConstants.resolvePublicUrl(t),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        placeholder: (_, _) => Image.asset(
          'assets/pngs/artist_profile.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        errorWidget: (_, _, _) => Image.asset(
          'assets/pngs/artist_profile.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    return Image.asset(t, fit: BoxFit.cover, alignment: Alignment.topCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // CustomScrollView for the main content
          RefreshIndicator(
            color: AppColors.buttonColor,
            backgroundColor: AppColors.background,
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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

        // Artist image (asset or network)
        Positioned.fill(child: _buildCoverImage(_artist.coverImageUrl)),

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
                          if (widget.artist.isVerified) ...[
                            6.row,
                            Image.asset(
                              widget.mediaType == 'Videos'
                                  ? 'assets/pngs/verify_green.png'
                                  : 'assets/pngs/verify.png',
                              width: 25.icon,
                              height: 25.icon,
                            ),
                          ],
                        ],
                      ),
                      8.column,
                      // Gift fans count
                      Text(
                        '${_followerFormat.format(_artist.followerCount)} Gift Fans',
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
                          Opacity(
                            opacity:
                                context
                                    .watch<ArtistProfileProvider>()
                                    .isActionInFlight
                                ? 0.55
                                : 1,
                            child: AbsorbPointer(
                              absorbing: context
                                  .watch<ArtistProfileProvider>()
                                  .isActionInFlight,
                              child: GlassButtonWidget(
                                text: _isFollowing ? 'Following' : 'Follow',
                                onTap: _toggleFollow,
                              ),
                            ),
                          ),
                          GlassButtonWidget(
                            text: 'Gift Me',
                            onTap: _showGiftBoxModal,
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

  void _showGiftBoxModal() {
    final provider = context.read<ArtistProfileProvider>();
    if (provider.isLoadingGifts) {
      AppToast.showInfo('Loading gifts...');
      return;
    }
    if (provider.gifts.isEmpty) {
      AppToast.showError('No gifts available at the moment.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: provider.gifts,
          onClose: () {
            Navigator.of(context).pop();
          },
          onGiftSelected: (GiftItem gift) {
            // TODO: Implement sending gift
          },
        );
      },
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
          NavigationButtonsWidget(
            mediaType: widget.mediaType,
            artistId: widget.artist.id,
            artistName: widget.artist.name,
          ),
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
                final albums = widget.mediaType == 'Videos'
                    ? _videoAlbumItems
                    : _albumItems;
                return AlbumsSectionWidget(
                  albums: albums,
                  onTap: () {},
                  onGiftCountTap: () {},
                  mediaType: widget.mediaType,
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
            songs: widget.mediaType == 'Videos'
                ? _videoMostPopular
                : _genreSongs,
            onSongTap: (song) {
              final uri = Uri(
                path: AppRouter.musicPlayer,
                queryParameters: {
                  'trackId': song.id,
                  'title': song.title,
                  'artistName': song.artist,
                  'albumName': 'Most Popular',
                  'backgroundImageUrl': song.albumArtUrl,
                  'isUnlocked': song.isUnlocked.toString(),
                },
              );
              context.push(uri.toString());
            },
            onPlayUnlockTap: (song) {
              setState(() {
                // Toggle play/unlock state
                final songsList = widget.mediaType == 'Videos'
                    ? _videoMostPopular
                    : _genreSongs;
                final index = songsList.indexOf(song);
                if (index != -1) {
                  if (widget.mediaType == 'Videos') {
                    _videoMostPopular[index] = _videoMostPopular[index]
                        .copyWith(
                          isUnlocked: !_videoMostPopular[index].isUnlocked,
                        );
                  } else {
                    _genreSongs[index] = _genreSongs[index].copyWith(
                      isUnlocked: !_genreSongs[index].isUnlocked,
                    );
                  }
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
            artists: widget.mediaType == 'Videos'
                ? _videoSimilarCreators
                : _trendingArtists,
            title: widget.mediaType == 'Videos'
                ? 'Similar Creators'
                : 'Similar artists',
            showLeadingIcon: false,
            mediaType: widget.mediaType,
          ),
        ],
      ),
    );
  }
}
