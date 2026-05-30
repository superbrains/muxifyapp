import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:muxify/features/music_player/widgets/muxify_branded_background.dart';
import 'package:muxify/features/music_player/widgets/queue_artwork_carousel.dart';
import 'package:muxify/features/music_player/widgets/queue_list_sheet.dart';
import 'package:muxify/features/music_player/widgets/song_info_overlay.dart';
import 'package:muxify/features/music_player/widgets/music_progress_bar.dart';
import 'package:muxify/features/music_player/widgets/playback_controls.dart';
import 'package:muxify/features/music_player/widgets/send_gifts_button.dart';
import 'package:muxify/features/music_player/widgets/unlock_confirm_modal.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/gift_box_modal.dart';

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

  // Auto-skip de-dup guard: the last queue index we already skipped past.
  // Prevents the post-frame callback from firing audio.next() repeatedly for
  // the same locked index while the queue settles after the skip.
  int? _lastAutoSkippedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hydrateAudio();
      _hydrateLikeStatus();
      // Warm the gift catalogue so the GIFTBOX opens with real types/costs.
      context.read<ArtistProfileProvider>().loadGiftTypes();
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
      unlockCostCoins: widget.unlockCostCoins ?? 0,
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

    final currentTrack = audio.currentTrack;
    final currentTrackId = (currentTrack?.id ?? '').trim();
    final widgetTrackId = (widget.trackId ?? '').trim();
    final trackId = currentTrackId.isNotEmpty ? currentTrackId : widgetTrackId;
    final isUnlocked = _resolveUnlocked(unlockedContent, currentTrack);
    final isLiked = trackId.isEmpty ? false : interaction.isLiked(trackId);
    final displayTitle = currentTrack?.title.trim().isNotEmpty == true
        ? currentTrack!.title
        : widget.title;
    final displayArtist = currentTrack?.artist.trim().isNotEmpty == true
        ? currentTrack!.artist
        : widget.artistName;
    final displayCover = currentTrack?.artworkUrl?.trim().isNotEmpty == true
        ? currentTrack!.artworkUrl
        : widget.backgroundImageUrl;

    // Auto-skip locked tracks during playback. Schedule on the next frame so
    // we don't trigger setState/playback calls while build is running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeAutoSkipLocked(audio, unlockedContent);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image — fallback chain:
          //   1. track cover (widget.backgroundImageUrl)
          //   2. artist avatar (resolved on init via artistId)
          //   3. branded Muxify background widget
          Positioned.fill(child: _buildPlayerBackground(displayCover)),

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
                  artistName: displayArtist ?? 'Omah Lay',
                  albumName: widget.albumName ?? 'Latest Release',
                  isUnlocked: isUnlocked,
                  onToggleUnlock: () =>
                      _handleUnlockTap(isUnlocked, trackId: trackId),
                ),

                // Lyrics Button
                LyricsButtonWidget(
                  icon: Icons.music_note_outlined,
                  text: _showLyrics ? 'Hide Lyrics' : 'Lyrics',
                  onTap: _toggleLyrics,
                ),

                // Horizontal queue artwork carousel — only when more than
                // one track is queued. With a single track we keep the
                // existing background-art-only layout.
                if (audio.queue.length > 1) ...[
                  20.column,
                  QueueArtworkCarousel(
                    queue: audio.queue,
                    currentIndex: audio.currentIndex,
                    audio: audio,
                  ),
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
                          songTitle: displayTitle ?? 'Moving',
                          artistName: displayArtist ?? 'Omah Lay',
                          isUnlocked: isUnlocked,
                          isLiked: isLiked,
                          isAdded: false,
                          onToggleLike: () => _handleToggleLike(trackId),
                          onToggleAdd: () =>
                              _handleAddToPlaylist(trackId, interaction),
                          onShare: () => _handleShare(trackId, interaction),
                          onUnlockSong: () =>
                              _handleUnlockTap(isUnlocked, trackId: trackId),
                          onShowQueue: () => QueueListSheet.show(context),
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

  /// Resolves the *currently displayed* track's unlock state. Priority:
  /// 1. UnlockedContentProvider for the active id (queue track id wins,
  ///    falling back to the route arg).
  /// 2. Track.isUnlocked from the AudioProvider's current queue track.
  /// 3. The route argument (`widget.isUnlocked`) when no queue track has
  ///    superseded it.
  /// Defaults to true (free track) when no lock signal exists.
  bool _resolveUnlocked(
    UnlockedContentProvider provider,
    Track? currentTrack,
  ) {
    final currentId = (currentTrack?.id ?? '').trim();
    final widgetId = (widget.trackId ?? '').trim();
    final activeId = currentId.isNotEmpty ? currentId : widgetId;
    if (activeId.isNotEmpty && provider.isUnlocked(activeId)) return true;
    if (currentTrack != null) {
      // Queue track is the source of truth once playback has started.
      return currentTrack.isUnlocked;
    }
    if (widget.isUnlocked == true) return true;
    if (widget.isUnlocked == false) return false;
    return true; // No lock signal — treat as free.
  }

  /// If the currently-playing queue track is locked and at least one other
  /// queue track is unlocked, advance past it. Skips at most once per index
  /// transition (de-duped via [_lastAutoSkippedIndex]).
  void _maybeAutoSkipLocked(
    AudioProvider audio,
    UnlockedContentProvider unlockedContent,
  ) {
    final track = audio.currentTrack;
    if (track == null) return;
    final idx = audio.currentIndex;
    if (idx == null) return;
    if (_lastAutoSkippedIndex == idx) return;

    final isCurrentUnlocked =
        track.isUnlocked || unlockedContent.isUnlocked(track.id);
    if (isCurrentUnlocked) return;

    final hasUnlockedElsewhere = audio.queue.any(
      (t) => t.id != track.id &&
          (t.isUnlocked || unlockedContent.isUnlocked(t.id)),
    );
    if (!hasUnlockedElsewhere) {
      // All locked — stop on this track so the user can unlock it.
      return;
    }

    _lastAutoSkippedIndex = idx;
    audio.next();
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

  Future<void> _handleUnlockTap(
    bool isCurrentlyUnlocked, {
    required String trackId,
  }) async {
    HapticFeedback.lightImpact();
    if (isCurrentlyUnlocked) {
      // Visual no-op — the icon shows the unlocked state for free / already-
      // unlocked tracks; tapping it again does nothing meaningful.
      return;
    }
    final id = trackId.trim();
    if (id.isEmpty) {
      await AppToast.showError('Track is not ready yet.');
      return;
    }
    final interaction = context.read<MusicPlayerInteractionProvider>();
    final unlockedContent = context.read<UnlockedContentProvider>();
    final audio = context.read<AudioProvider>();
    final currentTrack = audio.currentTrack;
    final trackTitle = (currentTrack?.title.trim().isNotEmpty == true
            ? currentTrack!.title
            : widget.title) ??
        'this song';
    final artistName = (currentTrack?.artist.trim().isNotEmpty == true
            ? currentTrack!.artist
            : widget.artistName) ??
        '';
    // Cost comes from the track itself: the active queue track wins, falling
    // back to the route argument. Never a hard-coded default.
    final unlockCost = (currentTrack?.unlockCostCoins ?? 0) > 0
        ? currentTrack!.unlockCostCoins
        : (widget.unlockCostCoins ?? 0);
    // Pull the live coin/Naira rate so the modal can show the ₦ equivalent.
    final rate = await WalletApiService().fetchCoinRate();
    if (!mounted) return;
    await UnlockConfirmModal.show(
      context,
      trackId: id,
      trackTitle: trackTitle,
      artistName: artistName,
      unlockCostCoins: unlockCost,
      coinsPerNairaMajor: rate.coinsPerNairaMajor,
      interaction: interaction,
      onUnlocked: () async {
        await unlockedContent.markUnlocked(id);
      },
    );
  }

  void _showGiftBoxModal() {
    final provider = context.read<ArtistProfileProvider>();
    final audio = context.read<AudioProvider>();
    final artistId =
        (audio.currentTrack?.artistId ?? widget.artistId ?? '').trim();
    if (artistId.isEmpty) {
      AppToast.showError('We could not identify the artist to gift.');
      return;
    }
    if (provider.isLoadingGifts) {
      AppToast.showInfo('Loading gifts...');
      return;
    }
    if (provider.gifts.isEmpty) {
      // Retry a load in case the warm-up call failed (e.g. cold start 401).
      provider.loadGiftTypes();
      AppToast.showError('No gifts available right now. Try again.');
      return;
    }

    final trackId =
        (audio.currentTrack?.id ?? widget.trackId ?? '').trim();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return GiftBoxModal(
          headerText: 'GIFTBOX',
          subHeaderText: 'Tap to send gift',
          giftItems: provider.gifts,
          recipientArtistId: artistId,
          trackId: trackId.isEmpty ? null : trackId,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  /// Returns the background image with fallbacks. The active queue track's
  /// cover wins (caller passes it in); if it fails or is empty we try the
  /// resolved artist avatar; otherwise we render the branded Muxify
  /// background.
  Widget _buildPlayerBackground(String? activeCover) {
    final cover = (activeCover ?? '').trim();
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
      return AuthNetworkImage(
        path: source,
        fit: BoxFit.cover,
        placeholder: onError(),
        errorWidget: onError(),
      );
    }
    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => onError(),
    );
  }
}
