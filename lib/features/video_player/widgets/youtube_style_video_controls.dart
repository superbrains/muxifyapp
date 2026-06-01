import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:video_player/video_player.dart';

/// A YouTube-grade custom control surface drawn over a [VideoPlayerController].
/// Single tap toggles the overlay (auto-hides after 3s while playing);
/// double-tap on the left/right half seeks ∓10s; the bottom bar carries a
/// scrubbable progress track with time labels, a mute toggle and a fullscreen
/// toggle; a centred play/pause button and a buffering spinner sit in the
/// middle. Works both inline and inside [FullscreenVideoPage] (same controller).
class YouTubeStyleVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  /// Optional top-bar affordances (mainly used in fullscreen).
  final VoidCallback? onBack;
  final String? title;

  const YouTubeStyleVideoControls({
    super.key,
    required this.controller,
    required this.onToggleFullscreen,
    this.isFullscreen = false,
    this.onBack,
    this.title,
  });

  @override
  State<YouTubeStyleVideoControls> createState() =>
      _YouTubeStyleVideoControlsState();
}

class _YouTubeStyleVideoControlsState extends State<YouTubeStyleVideoControls> {
  bool _visible = true;
  Timer? _hideTimer;

  // Brief "+10s" / "-10s" feedback shown after a double-tap seek.
  int _seekFeedback = 0; // -10, 0, or +10
  Timer? _seekFeedbackTimer;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _restartHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _seekFeedbackTimer?.cancel();
    super.dispose();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_c.value.isPlaying) setState(() => _visible = false);
    });
  }

  void _toggleVisible() {
    setState(() => _visible = !_visible);
    if (_visible) _restartHideTimer();
  }

  void _togglePlay() {
    HapticFeedback.selectionClick();
    if (_c.value.isPlaying) {
      _c.pause();
    } else {
      _c.play();
    }
    setState(() => _visible = true);
    _restartHideTimer();
  }

  void _seekBy(int seconds) {
    final pos = _c.value.position + Duration(seconds: seconds);
    final dur = _c.value.duration;
    final clamped = pos < Duration.zero
        ? Duration.zero
        : (pos > dur ? dur : pos);
    _c.seekTo(clamped);
    HapticFeedback.selectionClick();
    setState(() {
      _seekFeedback = seconds;
      _visible = true;
    });
    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _seekFeedback = 0);
    });
    _restartHideTimer();
  }

  void _toggleMute() {
    final muted = _c.value.volume == 0;
    _c.setVolume(muted ? 1.0 : 0.0);
    setState(() {});
    _restartHideTimer();
  }

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final mm = h > 0 ? m.toString().padLeft(2, '0') : m.toString();
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final value = _c.value;
        final isBuffering = value.isBuffering;
        final isPlaying = value.isPlaying;
        final muted = value.volume == 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Double-tap seek zones + single-tap toggle (left / right halves).
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleVisible,
                    onDoubleTap: () => _seekBy(-10),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleVisible,
                    onDoubleTap: () => _seekBy(10),
                  ),
                ),
              ],
            ),

            // Scrim + controls fade together.
            IgnorePointer(
              ignoring: !_visible,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),

            // Centred transport (hidden while buffering shows its spinner).
            IgnorePointer(
              ignoring: !_visible,
              child: AnimatedOpacity(
                opacity: _visible && !isBuffering ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: _RoundControl(
                    icon: isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 64,
                    iconSize: 40,
                    onTap: _togglePlay,
                  ),
                ),
              ),
            ),

            // Buffering spinner.
            if (isBuffering)
              const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                  ),
                ),
              ),

            // Double-tap seek feedback.
            if (_seekFeedback != 0)
              Align(
                alignment: _seekFeedback < 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.padding),
                  child: _SeekBadge(seconds: _seekFeedback),
                ),
              ),

            // Top bar (back + title) — fades with the rest.
            if (widget.onBack != null || (widget.title?.isNotEmpty ?? false))
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !_visible,
                  child: AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        8.padding,
                        8.padding,
                        12.padding,
                        0,
                      ),
                      child: Row(
                        children: [
                          if (widget.onBack != null)
                            _RoundControl(
                              icon: Icons.arrow_back_rounded,
                              size: 38,
                              iconSize: 22,
                              onTap: widget.onBack!,
                            ),
                          if (widget.title?.isNotEmpty ?? false) ...[
                            10.row,
                            Expanded(
                              child: Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15.font,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom bar: time · scrubber · mute · fullscreen.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !_visible,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      12.padding,
                      4.padding,
                      8.padding,
                      6.padding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 14,
                          child: VideoProgressIndicator(
                            _c,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            colors: VideoProgressColors(
                              playedColor: AppColors.buttonColor,
                              bufferedColor:
                                  AppColors.text.withValues(alpha: 0.3),
                              backgroundColor:
                                  AppColors.text.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_fmt(value.position)} / ${_fmt(value.duration)}',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 11.font,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            _BarIcon(
                              icon: muted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              onTap: _toggleMute,
                            ),
                            6.row,
                            _BarIcon(
                              icon: widget.isFullscreen
                                  ? Icons.fullscreen_exit_rounded
                                  : Icons.fullscreen_rounded,
                              onTap: () {
                                widget.onToggleFullscreen();
                                _restartHideTimer();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _RoundControl({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.text, size: iconSize),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: AppColors.text, size: 22),
      ),
    );
  }
}

class _SeekBadge extends StatelessWidget {
  final int seconds;
  const _SeekBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final forward = seconds > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            forward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
            color: AppColors.text,
            size: 30,
          ),
          const SizedBox(height: 2),
          Text(
            '${forward ? '+' : '-'}10s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Landscape, immersive fullscreen page that reuses the SAME controller as the
/// inline player, so playback position and buffering are continuous. Pops back
/// to portrait when the user exits fullscreen.
class FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final String? title;

  const FullscreenVideoPage({
    super.key,
    required this.controller,
    this.title,
  });

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = widget.controller.value.aspectRatio == 0
        ? 16 / 9
        : widget.controller.value.aspectRatio;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(widget.controller),
              YouTubeStyleVideoControls(
                controller: widget.controller,
                isFullscreen: true,
                title: widget.title,
                onBack: () => Navigator.of(context).maybePop(),
                onToggleFullscreen: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
