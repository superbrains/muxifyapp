import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/artist_profile/models/new_release_item.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/artist_profile/utils/release_playback_helper.dart';
import 'package:muxify/features/artist_profile/widgets/albums_section_widget.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';
import 'package:muxify/shared/widgets/glass_button_widget.dart';
import 'package:muxify/features/artist_profile/widgets/latest_release_banner_widget.dart';
import 'package:muxify/features/artist_profile/widgets/navigation_buttons_widget.dart';
import 'package:muxify/features/artist_profile/widgets/play_button_widget.dart';
import 'package:muxify/features/artist_profile/widgets/songs_list_widget.dart';
import 'package:muxify/features/artist_profile/widgets/top_icons_widget.dart';
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/home/providers/home_provider.dart';
import 'package:muxify/features/home/widgets/trending_artists_section.dart';
import 'package:shimmer/shimmer.dart';

class ArtistProfileScreen extends StatefulWidget {
  final TrendingArtist artist;
  final String? mediaType;

  const ArtistProfileScreen({super.key, required this.artist, this.mediaType});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  final NumberFormat _followerFormat = NumberFormat.decimalPattern();

  late bool _isFollowing;
  bool _isVideoMode = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.artist.isFollowing;
    _isVideoMode = widget.mediaType == 'Videos';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAll(forceRefresh: false);
    });
  }

  Future<void> _loadAll({required bool forceRefresh}) async {
    final id = widget.artist.id.trim();
    if (id.isEmpty) return;
    final name = widget.artist.name.trim().isEmpty
        ? 'Artist'
        : widget.artist.name.trim();

    final provider = context.read<ArtistProfileProvider>();
    final homeProvider = context.read<HomeProvider>();

    await Future.wait([
      provider.loadArtistProfile(id, forceRefresh: forceRefresh),
      provider.loadArtistTracks(id, name, forceRefresh: forceRefresh),
      provider.loadArtistAlbums(id, name, forceRefresh: forceRefresh),
      provider.loadArtistNewReleases(id, name, forceRefresh: forceRefresh),
      provider.loadGiftTypes(),
      provider.loadSimilarArtists(
        excludeId: id,
        homeProvider: homeProvider,
        forceRefresh: forceRefresh,
      ),
      if (_isVideoMode)
        provider.loadArtistVideos(id, name, forceRefresh: forceRefresh),
    ]);
  }

  Future<void> _toggleFollow() async {
    final provider = context.read<ArtistProfileProvider>();
    if (provider.isActionInFlight) return;

    final id = widget.artist.id.trim();
    if (id.isEmpty) {
      await AppToast.showError('Missing artist.');
      return;
    }

    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !_isFollowing);

    try {
      final r = wasFollowing
          ? await provider.unfollowArtist(id)
          : await provider.followArtist(id);

      if (!mounted || r == null) {
        if (mounted) setState(() => _isFollowing = wasFollowing);
        return;
      }

      setState(() => _isFollowing = r.isFollowing);

      final msg = r.message?.trim();
      if (msg != null && msg.isNotEmpty) {
        await AppToast.showInfo(msg);
      }
    } catch (e) {
      if (mounted) setState(() => _isFollowing = wasFollowing);
      await AppToast.showError(e.toString());
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAll(forceRefresh: true);
  }

  String _resolveCoverPath(ArtistProfileProvider provider) {
    final profile = provider.artistProfile;
    final candidates = <String?>[
      profile?.bannerUrl,
      profile?.avatarUrl,
      widget.artist.imageUrl,
    ];
    for (final raw in candidates) {
      final value = raw?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _displayName(ArtistProfileProvider provider) {
    final profileName = provider.artistProfile?.name.trim() ?? '';
    if (profileName.isNotEmpty) return profileName;
    final routeName = widget.artist.name.trim();
    return routeName.isEmpty ? 'Artist' : routeName;
  }

  int _displayFollowerCount(ArtistProfileProvider provider) {
    final profileCount = provider.artistProfile?.followerCount;
    if (profileCount != null && profileCount > 0) return profileCount;
    return widget.artist.followerCount;
  }

  bool _displayIsVerified(ArtistProfileProvider provider) {
    return provider.artistProfile?.isVerified ?? widget.artist.isVerified;
  }

  void _openRelease(NewReleaseItem release) {
    final type = release.type.toLowerCase();
    if (type == 'album') {
      context.push(AppRouter.albumDetails);
      return;
    }
    if (type == 'video') {
      context.push(AppRouter.videoPlayer);
      return;
    }
    ReleasePlaybackHelper.openFromRelease(
      context,
      release: release,
      albumName: 'Latest Release',
    );
  }

  void _openTrendingArtist(TrendingArtist artist) {
    final params = <String, String>{
      'artistId': artist.id,
      'artistName': artist.name,
      'followerCount': artist.followerCount.toString(),
      'isFollowing': artist.isFollowing.toString(),
      'isVerified': artist.isVerified.toString(),
      if ((artist.imageUrl ?? '').trim().isNotEmpty)
        'coverImageUrl': artist.imageUrl!.trim(),
      if (widget.mediaType != null && widget.mediaType!.trim().isNotEmpty)
        'mediaType': widget.mediaType!.trim(),
    };
    final uri = Uri(
      path: AppRouter.artistProfile,
      queryParameters: params,
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.buttonColor,
            backgroundColor: AppColors.background,
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
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
                    child: _buildProfileContent(),
                  ),
                ),
              ],
            ),
          ),
          TopIconsWidget(
            onBackTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRouter.home);
              }
            },
            onSearchTap: () {},
            onMenuTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildArtistImageWithOverlay() {
    return Consumer<ArtistProfileProvider>(
      builder: (context, provider, _) {
        final coverPath = _resolveCoverPath(provider);
        final displayName = _displayName(provider);
        final followerCount = _displayFollowerCount(provider);
        final isVerified = _displayIsVerified(provider);

        return Stack(
          children: [
            // Purple background gradient (visible while image loads / errors)
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
            Positioned.fill(child: _buildCoverImage(coverPath)),
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
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                    Positioned(
                      top: 20.padding,
                      left: 20.padding,
                      right: 20.padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading1.copyWith(
                                    fontSize: 35.font,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              if (isVerified) ...[
                                6.row,
                                Image.asset(
                                  _isVideoMode
                                      ? 'assets/pngs/verify_green.png'
                                      : 'assets/pngs/verify.png',
                                  width: 25.icon,
                                  height: 25.icon,
                                ),
                              ],
                            ],
                          ),
                          8.column,
                          Text(
                            '${_followerFormat.format(followerCount)} Gift Fans',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 16.font,
                              color: AppColors.text.withValues(alpha: 0.8),
                            ),
                          ),
                          20.column,
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(
                                opacity: provider.isActionInFlight ? 0.55 : 1,
                                child: AbsorbPointer(
                                  absorbing: provider.isActionInFlight,
                                  child: GlassButtonWidget(
                                    text: _isFollowing
                                        ? 'Following'
                                        : 'Follow',
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
                                onTap: _playFirstAvailable,
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
      },
    );
  }

  Widget _buildCoverImage(String pathOrUrl) {
    final t = pathOrUrl.trim();
    final placeholder = Image.asset(
      'assets/pngs/artist_profile.png',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );
    if (t.isEmpty) return placeholder;
    if (t.startsWith('assets/')) {
      return Image.asset(t, fit: BoxFit.cover, alignment: Alignment.topCenter);
    }
    return AuthNetworkImage(
      path: t,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: placeholder,
      errorWidget: placeholder,
    );
  }

  Future<void> _playFirstAvailable() async {
    final provider = context.read<ArtistProfileProvider>();
    final list = _isVideoMode ? provider.videos : provider.tracks;
    if (list.isEmpty) {
      await AppToast.showInfo('Nothing to play yet.');
      return;
    }
    final first = list.first;
    if (_isVideoMode) {
      _openRelease(first);
      return;
    }
    await ReleasePlaybackHelper.openFromRelease(
      context,
      release: first,
      albumName: 'Most Popular',
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
      builder: (BuildContext dialogContext) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: provider.gifts,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
          onGiftSelected: (GiftItem gift) {},
          onSendGift: (GiftItem gift) async {
            Navigator.of(dialogContext).pop();
            if (gift.id.isEmpty) {
              await AppToast.showError('Invalid gift selection.');
              return;
            }
            try {
              final response = await provider.sendGift(
                artistId: widget.artist.id,
                giftType: gift.id,
              );
              if (response != null && response.success) {
                await AppToast.showInfo(
                  response.message?.isNotEmpty == true
                      ? response.message!
                      : 'Gift sent!',
                );
              }
            } catch (e) {
              await AppToast.showError(e.toString());
            }
          },
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 70.padding),
      padding: EdgeInsets.symmetric(horizontal: 20.padding),
      child: Consumer<ArtistProfileProvider>(
        builder: (context, provider, _) {
          final tracks = _isVideoMode ? provider.videos : provider.tracks;
          final albums = _isVideoMode ? provider.videos : provider.albums;
          final isLoadingTracks = _isVideoMode
              ? provider.isLoadingVideos
              : provider.isLoadingTracks;
          final isLoadingAlbums = _isVideoMode
              ? provider.isLoadingVideos
              : provider.isLoadingAlbums;
          final tracksError = _isVideoMode
              ? provider.videosError
              : provider.tracksError;
          final albumsError = _isVideoMode
              ? provider.videosError
              : provider.albumsError;

          final latestRelease = provider.releases.isNotEmpty
              ? provider.releases.first
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NavigationButtonsWidget(
                mediaType: widget.mediaType,
                artistId: widget.artist.id,
                artistName: _displayName(provider),
              ),
              18.column,
              if (latestRelease != null)
                LatestReleaseBannerWidget(
                  release: latestRelease,
                  onTap: () => _openRelease(latestRelease),
                ),
              if (latestRelease != null) 30.column,
              _buildAlbumsCarousel(
                items: albums,
                isLoading: isLoadingAlbums,
                error: albumsError,
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
              _buildTracksList(
                items: tracks,
                isLoading: isLoadingTracks,
                error: tracksError,
              ),
              18.column,
              if (tracks.length > 4)
                Center(
                  child: GestureDetector(
                    onTap: () {},
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
                ),
              47.column,
              TrendingArtistsSection(
                artists: provider.similarArtists,
                title: _isVideoMode ? 'Similar Creators' : 'Similar artists',
                showLeadingIcon: false,
                mediaType: widget.mediaType,
                isLoading: provider.isLoadingSimilarArtists &&
                    provider.similarArtists.isEmpty,
                onArtistTap: _openTrendingArtist,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlbumsCarousel({
    required List<NewReleaseItem> items,
    required bool isLoading,
    required String? error,
  }) {
    if (isLoading && items.isEmpty) {
      return SizedBox(
        height: 430.maxHeight,
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF3A3A3A),
          child: Container(
            width: 365.maxWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.radius),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyCard(
        message: error ?? (_isVideoMode ? 'No videos yet.' : 'No albums yet.'),
        height: 200.maxHeight,
      );
    }

    final albumItems = items
        .map(
          (release) => release.toAlbumItem(
            giftCount: '0',
          ),
        )
        .toList();

    return SizedBox(
      height: 430.maxHeight,
      child: AlbumsSectionWidget(
        albums: albumItems,
        onTap: () => _openRelease(items.first),
        onGiftCountTap: () {},
        mediaType: widget.mediaType,
      ),
    );
  }

  Widget _buildTracksList({
    required List<NewReleaseItem> items,
    required bool isLoading,
    required String? error,
  }) {
    if (isLoading && items.isEmpty) {
      return Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 16.padding),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF2A2A2A),
              highlightColor: const Color(0xFF3A3A3A),
              child: Row(
                children: [
                  Container(
                    width: 40.maxWidth,
                    height: 40.maxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.radius),
                    ),
                  ),
                  16.row,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160.maxWidth,
                          height: 14,
                          color: Colors.white,
                        ),
                        8.column,
                        Container(
                          width: 90.maxWidth,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyCard(
        message: error ?? 'No releases yet.',
        height: 120.maxHeight,
      );
    }

    final songs = items.map((release) => release.toGenreSongItem()).toList();

    return SongsListWidget(
      songs: songs,
      onSongTap: (song) {
        final release = items.firstWhere(
          (r) => r.id == song.id,
          orElse: () => items.first,
        );
        _openRelease(release);
      },
      onPlayUnlockTap: (song) {
        _handlePlayUnlock(song.id);
      },
      onMenuTap: (song) {},
    );
  }

  Future<void> _handlePlayUnlock(String trackId) async {
    final provider = context.read<ArtistProfileProvider>();
    final list = _isVideoMode ? provider.videos : provider.tracks;
    final release = list.firstWhere(
      (r) => r.id == trackId,
      orElse: () => list.isNotEmpty
          ? list.first
          : NewReleaseItem(
              id: trackId,
              title: '',
              artist: '',
              coverImageUrl: '',
            ),
    );

    if (!release.isUnlocked && release.unlockCostCoins > 0) {
      try {
        if (_isVideoMode) {
          await provider.unlockVideo(release.id);
        } else {
          await provider.unlockTrack(release.id);
        }
        provider.markTrackUnlocked(release.id);
        if (mounted) {
          await context
              .read<UnlockedContentProvider>()
              .markUnlocked(release.id);
        }
        await AppToast.showInfo('Unlocked!');
      } catch (e) {
        await AppToast.showError(e.toString());
        return;
      }
    }

    if (!mounted) return;
    if (_isVideoMode) {
      _openRelease(release);
      return;
    }
    await ReleasePlaybackHelper.openFromRelease(
      context,
      release: release.copyWith(isUnlocked: true),
      albumName: 'Most Popular',
    );
  }

  Widget _buildEmptyCard({required String message, required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(
          color: AppColors.text.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.padding),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.font,
            color: AppColors.text.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
