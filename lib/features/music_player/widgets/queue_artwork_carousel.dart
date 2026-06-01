import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/providers/unlocked_content_provider.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/music_player/widgets/muxify_branded_background.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';
import 'package:muxify/shared/widgets/unlock_button.dart';

/// Horizontal artwork carousel for the player queue. Each page is a queue
/// track's cover art; the centered page is the currently playing track.
/// Swiping calls [AudioProvider.seekToIndex] to jump playback. When
/// [currentIndex] changes externally (e.g. auto-advance), the page animates
/// to follow.
class QueueArtworkCarousel extends StatefulWidget {
  final List<Track> queue;
  final int? currentIndex;
  final AudioProvider audio;

  /// Invoked when a locked track's Unlock CTA is tapped on its cover.
  final void Function(Track track)? onUnlockTrack;

  /// Invoked when the user swipes to a page, before playback is driven there,
  /// so the host can pin the index and keep auto-skip from yanking it away.
  final void Function(int index)? onUserSwipe;

  const QueueArtworkCarousel({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.audio,
    this.onUnlockTrack,
    this.onUserSwipe,
  });

  @override
  State<QueueArtworkCarousel> createState() => _QueueArtworkCarouselState();
}

class _QueueArtworkCarouselState extends State<QueueArtworkCarousel> {
  late PageController _controller;
  int _displayedIndex = 0;

  @override
  void initState() {
    super.initState();
    _displayedIndex = (widget.currentIndex ?? 0).clamp(
      0,
      widget.queue.isEmpty ? 0 : widget.queue.length - 1,
    );
    _controller = PageController(
      initialPage: _displayedIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  void didUpdateWidget(covariant QueueArtworkCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only react to a real currentIndex change (e.g. auto-advance, locked-
    // track auto-skip, queue-list jump). Frequent rebuilds from the audio
    // position stream must NOT animate the controller — that would yank the
    // carousel back during the async gap between a user swipe and the
    // matching currentIndexStream emission.
    final newIndex = widget.currentIndex;
    final oldIndex = oldWidget.currentIndex;
    if (newIndex == null || newIndex == oldIndex) return;
    if (newIndex == _displayedIndex) return; // already on this page
    if (!_controller.hasClients) return;
    final maxIndex = widget.queue.isEmpty ? 0 : widget.queue.length - 1;
    final clamped = newIndex.clamp(0, maxIndex);
    _displayedIndex = clamped;
    _controller.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (page == _displayedIndex) return;
    _displayedIndex = page;
    final activeIndex = widget.currentIndex;
    if (activeIndex == null || activeIndex != page) {
      // User swiped to a different page — pin it so the host suppresses the
      // locked-track auto-skip, then jump playback to that track.
      widget.onUserSwipe?.call(page);
      widget.audio.seekToIndex(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedContent = context.watch<UnlockedContentProvider>();
    // Fills whatever height the parent allocates (the player wraps this in an
    // Expanded so the artwork absorbs the leftover vertical space and the rest
    // of the player fits on screen without scrolling).
    return SizedBox.expand(
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.queue.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final track = widget.queue[index];
          final cover = (track.artworkUrl ?? '').trim();
          final locked = !(track.isUnlocked ||
              track.unlockCostCoins == 0 ||
              unlockedContent.isUnlocked(track.id));
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _coverImage(cover),
                  if (locked) _buildLockOverlay(track),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Dim veil + lock badge + a compact Unlock CTA pinned to the cover's
  /// bottom-right, so locked tracks always surface an unlock affordance —
  /// even ones playback skips.
  Widget _buildLockOverlay(Track track) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Subtle dim so the cover clearly reads as locked.
        Container(color: Colors.black.withValues(alpha: 0.45)),
        Center(
          child: Icon(Icons.lock_rounded, color: AppColors.text, size: 40.icon),
        ),
        // Compact Unlock pill, bottom-right.
        Positioned(
          right: 12.padding,
          bottom: 12.padding,
          child: UnlockButton(
            text: 'Unlock',
            iconPath: 'assets/pngs/Bitcoin_musixfy.png',
            onTap: () => widget.onUnlockTrack?.call(track),
            backgroundColor: AppColors.toggleSelected,
            iconColor: AppColors.buttonColor,
            iconSize: 16.icon,
            fontSize: 12.font,
            borderRadius: 20.radius,
            padding: EdgeInsets.symmetric(
              horizontal: 12.padding,
              vertical: 7.padding,
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverImage(String cover) {
    final fallback = Container(
      color: AppColors.background,
      child: const MuxifyBrandedBackground(),
    );
    if (cover.isEmpty) return fallback;
    // AuthNetworkImage resolves the path against the API base and attaches the
    // JWT, so the authenticated /api/v1/media/cover/* proxy returns the art
    // instead of 401. Absolute CDN URLs pass through untouched.
    return AuthNetworkImage(
      path: cover,
      fit: BoxFit.cover,
      placeholder: fallback,
      errorWidget: fallback,
    );
  }
}
