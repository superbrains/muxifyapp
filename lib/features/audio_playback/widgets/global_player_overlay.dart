import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/widgets/persistent_mini_player.dart';

/// Wraps the whole app so the [PersistentMiniPlayer] occupies its own row at
/// the bottom of the viewport whenever a track is active. Hides while the
/// full-screen player is mounted, driven by [AppRouter.fullPlayerVisible]
/// which the player flips in initState/dispose — so the mini-player stays
/// hidden even when the player opens a dialog or bottom sheet on top.
class GlobalPlayerOverlay extends StatelessWidget {
  const GlobalPlayerOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: child),
          ValueListenableBuilder<bool>(
            valueListenable: AppRouter.fullPlayerVisible,
            builder: (context, fullPlayerOpen, _) {
              if (fullPlayerOpen) {
                return const SizedBox.shrink();
              }
              return const PersistentMiniPlayer();
            },
          ),
        ],
      ),
    );
  }
}
