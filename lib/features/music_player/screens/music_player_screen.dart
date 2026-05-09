import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/core/utils/logger.dart';
import 'package:muxify/features/artist_profile/providers/artist_profile_provider.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/music_player/models/track_share_info.dart';
import 'package:muxify/features/music_player/providers/music_player_interaction_provider.dart';
import 'package:muxify/features/music_player/widgets/add_to_playlist_sheet.dart';
import 'package:muxify/features/music_player/widgets/lyrics_overlay.dart';
import 'package:muxify/features/music_player/widgets/music_player_top_bar.dart';
import 'package:muxify/features/music_player/widgets/lyrics_button_widget.dart';
import 'package:muxify/features/music_player/widgets/locked_song_image_list.dart';
import 'package:muxify/features/music_player/widgets/muxify_branded_background.dart';
import 'package:muxify/features/music_player/widgets/song_info_overlay.dart';
import 'package:muxify/features/music_player/widgets/music_progress_bar.dart';
import 'package:muxify/features/music_player/widgets/playback_controls.dart';
import 'package:muxify/features/music_player/widgets/send_gifts_button.dart';
import 'package:muxify/features/music_player/widgets/unlock_confirm_modal.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';
import 'package:muxify/features/statistics/models/gift_item.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String? trackId;
  final String? title;
  final String? artistName;
  final String? artistId;
  final String? albumName;
  final String? backgroundImageUrl;
  final String? audioUrl;
  final bool? isUnlocked;
  final int? unlockCostCoins;

  const MusicPlayerScreen({
    super.key,
    this.trackId,
    this.title,
    this.artistName,
    this.artistId,
    this.albumName,
    this.backgroundImageUrl,
    this.audioUrl,
    this.isUnlocked,
    this.unlockCostCoins,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool _showLyrics = false;

  // Resolved artist avatar (image fallback chain step 2). Populated lazily
  // when the track has no cover but we have an artistId.
  String? _resolvedArtistAvatar;

  // Mock images for locked song horizontal list
  final List<String> _lockedSongImages = [
    'assets/pngs/follows.png',
    'assets/pngs/latest_release.png',
    'assets/pngs/active_play.png',
    'assets/pngs/follows.png',
    'assets/pngs/latest_release.png',
    'assets/pngs/active_play.png',
  ];

  // Mock gift items for the gift box modal
  final List<GiftItem> _giftItems = [
    GiftItem(
      id: '1',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj1.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '2',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj4.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '3',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj3.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '4',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
    ),
    GiftItem(
      id: '5',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '6',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj6.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '7',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj1.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '8',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '9',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '10',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg2.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '11',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg3.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '12',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg4.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '13',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg5.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '14',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg6.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '15',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg1.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
    GiftItem(
      id: '16',
      name: 'Big Box',
      backgroundImage: 'assets/pngs/gift_bg7.png',
      emojiImage: 'assets/pngs/emoj7.png',
      stickerText: 'X20',
      count: 20,
      amount: 100250,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hydrateAudio();
      _hydrateLikeStatus();
    });
    _resolveBackgroundFallbacks();
  }

  /// Image fallback chain step 2: when the route didn't carry a track cover
  /// but did carry an artistId, fetch the artist's avatar URL once and
  /// re-render the background. If this fails we silently fall through to
  /// the [MuxifyBrandedBackground] step.
  Future<void> _resolveBackgroundFallbacks() async {
    final cover = (widget.backgroundImageUrl ?? '').trim();
    final artistId = (widget.artistId ?? '').trim();
    if (cover.isNotEmpty || artistId.isEmpty) return;
    try {
      final profile = await context
          .read<ArtistProfileProvider>()
          .getArtistPublicProfile(artistId);
      if (!mounted) return;
      final avatar = (profile.avatarUrl ?? '').trim();
      if (avatar.isEmpty) return;
      setState(() => _resolvedArtistAvatar = avatar);
    } catch (e, st) {
      Logger.warning('Music player artist avatar fallback failed: $e');
      Logger.debug(st.toString());
    }
  }

  /// If the route was opened with a different track than the one currently
  /// loaded in the global [AudioProvider], replace the queue and start
  /// playback. If we land here from the mini-player tap (same trackId), the
  /// existing playback continues untouched.
  Future<void> _hydrateAudio() async {
    final audio = context.read<AudioProvider>();
    final trackId = (widget.trackId ?? '').trim();
    if (trackId.isEmpty) return;
    if (audio.isCurrent(trackId)) return;

    final track = Track(
      id: trackId,
      title: widget.title ?? '',
      artist: widget.artistName ?? '',
      artistId: widget.artistId,
      albumName: widget.albumName,
      artworkUrl: widget.backgroundImageUrl,
      audioUrl: widget.audioUrl,
      isUnlocked: widget.isUnlocked ?? true,
    );
    await audio.playSingle(track);
  }

  /// Pulls the heart-on/off state for the current track from the backend so
  /// the heart icon survives leaving and re-entering the player.
  Future<void> _hydrateLikeStatus() async {
    final trackId = (widget.trackId ?? '').trim();
    if (trackId.isEmpty) return;
    await context
        .read<MusicPlayerInteractionProvider>()
        .hydrateLikeStatus(trackId);
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final interaction = context.watch<MusicPlayerInteractionProvider>();
    final unlockedContent = context.watch<UnlockedContentProvider>();
    final position = audio.position.inMilliseconds / 1000;
    final duration = audio.duration.inMilliseconds / 1000;

    final trackId = (widget.trackId ?? '').trim();
    final isUnlocked = _resolveUnlocked(unlockedContent);
    final isLiked = trackId.isEmpty ? false : interaction.isLiked(trackId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image — fallback chain:
          //   1. track cover (widget.backgroundImageUrl)
          //   2. artist avatar (resolved on init via artistId)
          //   3. branded Muxify background widget
          Positioned.fill(child: _buildPlayerBackground()),

          // Dark overlay for unlocked songs only
          if (isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

          // Blur effect for locked songs only
          if (!isUnlocked)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // Lyrics overlay — fades in over the artwork while leaving the
          // playback controls (rendered after this in the Stack) tappable.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _showLyrics
                ? const LyricsOverlay(key: ValueKey('lyrics-overlay'))
                : const SizedBox.shrink(key: ValueKey('lyrics-overlay-hidden')),
          ),

          // Content
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                // Top Bar
                MusicPlayerTopBar(
                  artistName: widget.artistName ?? 'Omah Lay',
                  albumName: widget.albumName ?? 'Latest Release',
                  isUnlocked: isUnlocked,
                  onToggleUnlock: () => _handleUnlockTap(isUnlocked),
                ),

                // Lyrics Button
                LyricsButtonWidget(
                  icon: Icons.music_note_outlined,
                  text: _showLyrics ? 'Hide Lyrics' : 'Lyrics',
                  onTap: _toggleLyrics,
                ),

                // Horizontal image list for locked songs
                if (!isUnlocked) ...[
                  20.column,
                  LockedSongImageList(images: _lockedSongImages),
                  20.column,
                ] else
                  Spacer(),
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 22.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Song Info Overlay
                        SongInfoOverlay(
                          songTitle: widget.title ?? 'Moving',
                          artistName: widget.artistName ?? 'Omah Lay',
                          isUnlocked: isUnlocked,
                          isLiked: isLiked,
                          isAdded: false,
                          onToggleLike: () => _handleToggleLike(trackId),
                          onToggleAdd: () =>
                              _handleAddToPlaylist(trackId, interaction),
                          onShare: () => _handleShare(trackId, interaction),
                          onUnlockSong: () => _handleUnlockTap(isUnlocked),
                          onShowLyrics: _toggleLyrics,
                        ),

                        30.column,
                        // Progress Bar
                        MusicProgressBar(
                          currentPosition: position.clamp(
                            0,
                            duration > 0 ? duration : position,
                          ),
                          totalDuration: duration <= 0 ? 1 : duration,
                          onChanged: (value) {
                            // Slider is fed by the provider; live drag preview
                            // is handled by onChangeEnd seeking the player.
                          },
                          onChangeEnd: (value) {
                            audio.seek(
                              Duration(milliseconds: (value * 1000).toInt()),
                            );
                          },
                        ),
                        20.column,
                        // Playback Controls
                        PlaybackControls(
                          isPlaying: audio.isPlaying,
                          isRepeating: audio.isRepeating,
                          isShuffled: audio.isShuffled,
                          onTogglePlay: audio.togglePlayPause,
                          onPrevious: () {
                            HapticFeedback.lightImpact();
                            audio.previous();
                          },
                          onNext: () {
                            HapticFeedback.lightImpact();
                            audio.next();
                          },
                          onToggleRepeat: audio.toggleRepeat,
                          onToggleShuffle: audio.toggleShuffle,
                        ),
                        54.column,
                        // Send Gifts Button
                        SendGiftsButton(onTap: _showGiftBoxModal),
                        20.column, // Extra padding at bottom
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

  /// Resolves the track's unlock state from the union of:
  /// 1. the route argument (`widget.isUnlocked`)
  /// 2. the persisted [UnlockedContentProvider] for this trackId
  /// Defaults to true (free track) when neither hint is present.
  bool _resolveUnlocked(UnlockedContentProvider provider) {
    if (widget.isUnlocked == true) return true;
    final trackId = (widget.trackId ?? '').trim();
    if (trackId.isNotEmpty && provider.isUnlocked(trackId)) return true;
    if (widget.isUnlocked == false) return false;
    return true; // No lock signal — treat as free.
  }

  void _toggleLyrics() {
    setState(() => _showLyrics = !_showLyrics);
  }

  Future<void> _handleToggleLike(String trackId) async {
    HapticFeedback.lightImpact();
    if (trackId.isEmpty) return;
    final ok = await context
        .read<MusicPlayerInteractionProvider>()
        .toggleLike(trackId);
    if (!ok && mounted) {
      await AppToast.showError('Could not update favourite. Try again.');
    }
  }

  Future<void> _handleAddToPlaylist(
    String trackId,
    MusicPlayerInteractionProvider interaction,
  ) async {
    HapticFeedback.lightImpact();
    if (trackId.isEmpty) {
      await AppToast.showError('Track is not ready yet.');
      return;
    }
    await AddToPlaylistSheet.show(
      context,
      trackId: trackId,
      trackTitle: widget.title ?? 'this song',
      interaction: interaction,
    );
  }

  Future<void> _handleShare(
    String trackId,
    MusicPlayerInteractionProvider interaction,
  ) async {
    HapticFeedback.lightImpact();
    if (trackId.isEmpty) {
      await AppToast.showError('Track is not ready yet.');
      return;
    }
    try {
      final TrackShareInfo info = await interaction.shareTrack(trackId);
      if (!mounted) return;
      // Pick the share-source rect from a sensible iPad anchor; on phones
      // this is ignored.
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        info.shareableText,
        subject: info.title.isEmpty ? null : info.title,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (!mounted) return;
      await AppToast.showError('Could not share track.');
      Logger.warning('Share track failed: $e');
    }
  }

  Future<void> _handleUnlockTap(bool isCurrentlyUnlocked) async {
    HapticFeedback.lightImpact();
    if (isCurrentlyUnlocked) {
      // Visual no-op — the icon shows the unlocked state for free / already-
      // unlocked tracks; tapping it again does nothing meaningful.
      return;
    }
    final trackId = (widget.trackId ?? '').trim();
    if (trackId.isEmpty) {
      await AppToast.showError('Track is not ready yet.');
      return;
    }
    final interaction = context.read<MusicPlayerInteractionProvider>();
    final unlockedContent = context.read<UnlockedContentProvider>();
    await UnlockConfirmModal.show(
      context,
      trackId: trackId,
      trackTitle: widget.title ?? 'this song',
      artistName: widget.artistName ?? '',
      unlockCostCoins: widget.unlockCostCoins ?? 100,
      interaction: interaction,
      onUnlocked: () async {
        await unlockedContent.markUnlocked(trackId);
      },
    );
  }

  void _showGiftBoxModal() {
    final provider = context.read<ArtistProfileProvider>();
    final artistId = (widget.artistId ?? '').trim();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: _giftItems,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
          onGiftSelected: (GiftItem gift) {},
          // Demo mode: short-circuit the coin/wallet check and call the real
          // gift API as soon as a gift is selected. Mirrors the wiring used
          // on the artist profile screen.
          onSendGift: artistId.isEmpty
              ? null
              : (GiftItem gift) async {
                  Navigator.of(dialogContext).pop();
                  if (gift.id.isEmpty) {
                    await AppToast.showError('Invalid gift selection.');
                    return;
                  }
                  try {
                    final response = await provider.sendGift(
                      artistId: artistId,
                      giftType: gift.id,
                      trackId: widget.trackId,
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

  /// Returns the background image with fallbacks. The track cover wins; if it
  /// fails or is empty we try the resolved artist avatar; otherwise we render
  /// the branded Muxify background.
  Widget _buildPlayerBackground() {
    final cover = (widget.backgroundImageUrl ?? '').trim();
    if (cover.isNotEmpty) {
      return _networkOrAsset(cover, onError: _avatarOrBranded);
    }
    return _avatarOrBranded();
  }

  Widget _avatarOrBranded() {
    final avatar = (_resolvedArtistAvatar ?? '').trim();
    if (avatar.isNotEmpty) {
      return _networkOrAsset(
        avatar,
        onError: () => const MuxifyBrandedBackground(),
      );
    }
    return const MuxifyBrandedBackground();
  }

  Widget _networkOrAsset(String source, {required Widget Function() onError}) {
    final lower = source.toLowerCase();
    final isRemote = lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        source.startsWith('/');
    if (isRemote) {
      return Image.network(
        ApiConstants.resolvePublicUrl(source),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => onError(),
      );
    }
    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => onError(),
    );
  }
}
