import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/ads/widgets/audio_ad_overlay.dart';
import 'package:muxify/features/audio_playback/widgets/persistent_mini_player.dart';

/// Wraps the whole app so the [PersistentMiniPlayer] occupies its own row at
/// the bottom of the viewport whenever a track is active. Hides while the
/// full-screen player is mounted ([AppRouter.fullPlayerVisible]) or while a
/// screen explicitly suppresses it ([AppRouter.miniPlayerSuppressed], e.g. the
/// video player). Both flags are flipped in initState/dispose so the mini-player
/// stays hidden even when the player opens a dialog, bottom sheet or fullscreen
/// route on top.
class GlobalPlayerOverlay extends StatelessWidget {
  const GlobalPlayerOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: child),
              ValueListenableBuilder<bool>(
                valueListenable: AppRouter.fullPlayerVisible,
                builder: (context, fullPlayerOpen, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: AppRouter.miniPlayerSuppressed,
                    builder: (context, suppressed, _) {
                      if (fullPlayerOpen || suppressed) {
                        return const SizedBox.shrink();
                      }
                      return const PersistentMiniPlayer();
                    },
                  );
                },
              ),
            ],
          ),
          // Audio-ad interstitial sits above everything when active.
          const AudioAdOverlay(),
        ],
      ),
    );
  }
}
