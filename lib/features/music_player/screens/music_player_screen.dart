import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/core/widgets/muxify_branded_loader.dart';
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
import 'package:muxify/shared/widgets/unlock_celebration_overlay.dart';

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

  // The queue index the user explicitly swiped to in the cover carousel.
  // Auto-skip never moves off a user-pinned index, so a locked track the user
  // chose to view stays put long enough to surface its Unlock CTA.
  int? _userPinnedIndex;

  // Surfaces playback failures (e.g. an unrecoverable stream URL) as a toast
  // so the user is never left staring at a silent, dead player.
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    // Hide the persistent mini-player while the full player owns the screen.
    _setFullPlayerVisible(true);
    _errorSub = context.read<AudioProvider>().errorStream.listen((message) {
      if (!mounted) return;
      AppToast.showError(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hydrateAudio();
      _hydrateLikeStatus();
      // Warm the gift catalogue so the GIFTBOX opens with real types/costs.
      context.read<ArtistProfileProvider>().loadGiftTypes();
    });
    _resolveBackgroundFallbacks();
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    // Restore the mini-player once the full player is popped. Dialogs/bottom
    // sheets pushed on top don't dispose this screen, so it stays hidden until
    // the player itself closes.
    _setFullPlayerVisible(false);
    super.dispose();
  }

  /// Flip the global [AppRouter.fullPlayerVisible] notifier safely.
  ///
  /// [GlobalPlayerOverlay] listens to this notifier with a
  /// [ValueListenableBuilder]. When this screen is mounted (or removed) as part
  /// of a route transition that runs inside the build/layout phase, mutating
  /// the notifier synchronously would mark that builder dirty mid-build and
  /// throw "setState() called during build". If we're mid-frame, defer the
  /// mutation to the post-frame callback; otherwise apply it immediately so the
  /// mini-player toggles without a one-frame flash.
  void _setFullPlayerVisible(bool visible) {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.fullPlayerVisible.value = visible;
      });
    } else {
      AppRouter.fullPlayerVisible.value = visible;
    }
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
    // A collection load (e.g. tapping a genre card) opens the player and kicks
    // off loadAndPlay for the whole queue before this runs. Don't fire a
    // competing single-track load against the same singleton player.
    if (audio.isPreparing) return;

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
    // `read` for actions and one-shot reads; the high-frequency position
    // stream is consumed ONLY by the progress bar (wrapped in a Selector
    // below), so the rest of the player no longer rebuilds on every tick.
    final audio = context.read<AudioProvider>();
    final interaction = context.watch<MusicPlayerInteractionProvider>();
    final unlockedContent = context.watch<UnlockedContentProvider>();

    // Reactive but low-frequency playback state — rebuild only when these
    // discrete values change, never on position ticks.
    final isPlaying = context.select<AudioProvider, bool>((a) => a.isPlaying);
    final isRepeating =
        context.select<AudioProvider, bool>((a) => a.isRepeating);
    final isShuffled =
        context.select<AudioProvider, bool>((a) => a.isShuffled);
    final isPreparing =
        context.select<AudioProvider, bool>((a) => a.isPreparing);
    final currentIndex =
        context.select<AudioProvider, int?>((a) => a.currentIndex);
    // Subscribe to queue-size changes so the carousel re-reads `audio.queue`
    // (which returns a fresh unmodifiable copy each call) when it changes.
    context.select<AudioProvider, int>((a) => a.queue.length);
    final currentTrack =
        context.select<AudioProvider, Track?>((a) => a.currentTrack);

    final currentTrackId = (currentTrack?.id ?? '').trim();
    final widgetTrackId = (widget.trackId ?? '').trim();
    final trackId = currentTrackId.isNotEmpty ? currentTrackId : widgetTrackId;
    final isUnlocked = _resolveUnlocked(unlockedContent, currentTrack);
    final unlockCost = _resolveUnlockCost(currentTrack);
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

          // Blurred, darkened "theme" derived from the cover art. Applied in
          // every state so single- and multi-track players look consistent: a
          // soft themed background sits behind the boxed cover carousel. Locked
          // tracks get a slightly stronger darkening on top of the same blur.
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isUnlocked
                        ? [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.85),
                          ]
                        : [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                    stops: const [0.0, 0.55, 1.0],
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

                // Boxed cover-art carousel — shown for both single- and
                // multi-track queues (PageView handles a single item with no
                // peeking neighbour) so the layout is consistent. Wrapped in
                // Expanded so the artwork absorbs all leftover vertical space
                // and the controls block below stays on screen without
                // scrolling.
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.padding),
                    child: QueueArtworkCarousel(
                      // queueLength selected above forces a rebuild (with a
                      // fresh `audio.queue` read) when the queue changes.
                      queue: audio.queue,
                      currentIndex: currentIndex,
                      audio: audio,
                      onUnlockTrack: _handleUnlockForTrack,
                      onUserSwipe: (i) => _userPinnedIndex = i,
                    ),
                  ),
                ),

                // Controls block — fixed height, pinned at the bottom.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Song Info Overlay
                      SongInfoOverlay(
                        songTitle: displayTitle ?? 'Moving',
                        artistName: displayArtist ?? 'Omah Lay',
                        isUnlocked: isUnlocked,
                        unlockCostCoins: unlockCost,
                        isLiked: isLiked,
                        isAdded: false,
                        onToggleLike: () => _handleToggleLike(trackId),
                        onToggleAdd: () =>
                            _handleAddToPlaylist(trackId, interaction),
                        onShare: () => _handleShare(trackId, interaction),
                        onUnlockSong: () =>
                            _handleUnlockTap(isUnlocked, trackId: trackId),
                        onShowQueue: () => QueueListSheet.show(
                          context,
                          onUnlockTrack: _handleUnlockForTrack,
                        ),
                      ),

                      16.column,
                      // Progress Bar — isolated in a Selector so the
                      // high-frequency position stream rebuilds only the bar,
                      // not the whole player.
                      Selector<AudioProvider, ({double position, double duration})>(
                        selector: (_, a) => (
                          position: a.position.inMilliseconds / 1000,
                          duration: a.duration.inMilliseconds / 1000,
                        ),
                        builder: (context, data, _) {
                          final position = data.position;
                          final duration = data.duration;
                          return MusicProgressBar(
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
                          );
                        },
                      ),
                      16.column,
                      // Playback Controls
                      PlaybackControls(
                        isPlaying: isPlaying,
                        isRepeating: isRepeating,
                        isShuffled: isShuffled,
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
                      20.column,
                      // Send Gifts Button
                      SendGiftsButton(onTap: _showGiftBoxModal),
                      12.column, // Extra padding at bottom
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Branded loader — covers the window from tapping Play until the
          // first source is audible (queue resolution + buffering). Fades out
          // once playback is ready so the player chrome underneath takes over.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isPreparing,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isPreparing
                    ? const MuxifyBrandedLoader(
                        key: ValueKey('player-loader'),
                        message: 'Loading…',
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('player-loader-hidden'),
                      ),
              ),
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
    // A zero-cost track is free: treat it as unlocked so there's no lock icon,
    // no "Unlock Song" button, and it never gets auto-skipped as if paywalled.
    if (_resolveUnlockCost(currentTrack) == 0) return true;
    if (currentTrack != null) {
      // Queue track is the source of truth once playback has started.
      return currentTrack.isUnlocked;
    }
    if (widget.isUnlocked == true) return true;
    if (widget.isUnlocked == false) return false;
    return true; // No lock signal — treat as free.
  }

  /// The real per-track unlock price: the active queue track wins (it's the
  /// authoritative source once playback starts), falling back to the route
  /// argument. Never a hard-coded default — 0 means free.
  int _resolveUnlockCost(Track? currentTrack) {
    final queueCost = currentTrack?.unlockCostCoins ?? 0;
    if (queueCost > 0) return queueCost;
    return widget.unlockCostCoins ?? 0;
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
    // The user deliberately swiped here (e.g. to unlock it) — don't yank away.
    if (_userPinnedIndex == idx) return;

    final isCurrentUnlocked = track.isUnlocked ||
        track.unlockCostCoins == 0 ||
        unlockedContent.isUnlocked(track.id);
    if (isCurrentUnlocked) return;

    final hasUnlockedElsewhere = audio.queue.any(
      (t) => t.id != track.id &&
          (t.isUnlocked ||
              t.unlockCostCoins == 0 ||
              unlockedContent.isUnlocked(t.id)),
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
    final unlockCost = _resolveUnlockCost(currentTrack);
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
        if (!mounted) return;
        // Celebrate the unlock with the same firework splash as gifting.
        UnlockCelebrationOverlay.show(
          context,
          coverImage:
              (currentTrack?.artworkUrl ?? widget.backgroundImageUrl) ?? '',
          title: trackTitle,
          subtitle: artistName,
          caption: 'Song unlocked',
        );
        // While locked, this track was excluded from playback (the stream
        // endpoint returned 403, so no URL resolved). Now that it's unlocked
        // the backend will return the stream URL, so re-resolve and start it
        // immediately — the user shouldn't have to leave and refresh.
        final unlockedTrack = Track(
          id: id,
          title: trackTitle,
          artist: artistName,
          artistId: currentTrack?.artistId ?? widget.artistId,
          albumName: currentTrack?.albumName ?? widget.albumName,
          artworkUrl: currentTrack?.artworkUrl ?? widget.backgroundImageUrl,
          isUnlocked: true,
          unlockCostCoins: 0,
        );
        await audio.playSingle(unlockedTrack);
      },
    );
  }

  /// Unlock flow for an explicit queue track — e.g. a locked cover tapped in
  /// the carousel, which may not be the currently-playing track. Mirrors
  /// [_handleUnlockTap] but sources all of its data from [track].
  Future<void> _handleUnlockForTrack(Track track) async {
    HapticFeedback.lightImpact();
    final id = track.id.trim();
    if (id.isEmpty) {
      await AppToast.showError('Track is not ready yet.');
      return;
    }
    final unlockedContent = context.read<UnlockedContentProvider>();
    // Free / already-unlocked tracks have nothing to unlock.
    if (track.unlockCostCoins == 0 ||
        track.isUnlocked ||
        unlockedContent.isUnlocked(id)) {
      return;
    }
    final interaction = context.read<MusicPlayerInteractionProvider>();
    final audio = context.read<AudioProvider>();
    final trackTitle =
        track.title.trim().isNotEmpty ? track.title : 'this song';
    final artistName = track.artist;
    // Pull the live coin/Naira rate so the modal can show the ₦ equivalent.
    final rate = await WalletApiService().fetchCoinRate();
    if (!mounted) return;
    await UnlockConfirmModal.show(
      context,
      trackId: id,
      trackTitle: trackTitle,
      artistName: artistName,
      unlockCostCoins: track.unlockCostCoins,
      coinsPerNairaMajor: rate.coinsPerNairaMajor,
      interaction: interaction,
      onUnlocked: () async {
        await unlockedContent.markUnlocked(id);
        if (!mounted) return;
        UnlockCelebrationOverlay.show(
          context,
          coverImage: track.artworkUrl ?? '',
          title: trackTitle,
          subtitle: artistName,
          caption: 'Song unlocked',
        );
        // Now unlocked, the stream URL will resolve — play it immediately.
        final unlockedTrack = Track(
          id: id,
          title: trackTitle,
          artist: artistName,
          artistId: track.artistId,
          albumName: track.albumName,
          artworkUrl: track.artworkUrl,
          isUnlocked: true,
          unlockCostCoins: 0,
        );
        await audio.playSingle(unlockedTrack);
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
