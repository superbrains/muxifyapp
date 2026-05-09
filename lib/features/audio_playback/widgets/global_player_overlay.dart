import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/widgets/persistent_mini_player.dart';

/// Wraps the whole app so the [PersistentMiniPlayer] occupies its own row at
/// the bottom of the viewport whenever a track is active. Hides only when
/// the topmost route is `/music-player`, driven by a NavigatorObserver
/// installed on the GoRouter — fires on push, pop, and replace.
class GlobalPlayerOverlay extends StatelessWidget {
  const GlobalPlayerOverlay({super.key, required this.child});

  final Widget child;

  // GoRoute names registered in AppRouter — see `name:` on the music-player
  // route. The route name is what the NavigatorObserver reports.
  static const String _musicPlayerRouteName = 'music-player';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: child),
          ValueListenableBuilder<String?>(
            valueListenable: AppRouter.topRouteName,
            builder: (context, topRoute, _) {
              if (topRoute == _musicPlayerRouteName) {
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
