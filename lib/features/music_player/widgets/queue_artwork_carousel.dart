import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/features/audio_playback/models/track.dart';
import 'package:muxify/features/audio_playback/providers/audio_provider.dart';
import 'package:muxify/features/music_player/widgets/muxify_branded_background.dart';
import 'package:muxify/shared/widgets/auth_network_image.dart';

/// Horizontal artwork carousel for the player queue. Each page is a queue
/// track's cover art; the centered page is the currently playing track.
/// Swiping calls [AudioProvider.seekToIndex] to jump playback. When
/// [currentIndex] changes externally (e.g. auto-advance), the page animates
/// to follow.
class QueueArtworkCarousel extends StatefulWidget {
  final List<Track> queue;
  final int? currentIndex;
  final AudioProvider audio;

  const QueueArtworkCarousel({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.audio,
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
      // User swiped to a different page — jump playback to that track.
      widget.audio.seekToIndex(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.maxHeight,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.queue.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final track = widget.queue[index];
          final cover = (track.artworkUrl ?? '').trim();
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: _coverImage(cover),
            ),
          );
        },
      ),
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
