import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/widgets/persistent_mini_player.dart';

/// Wraps the whole app so the [PersistentMiniPlayer] occupies its own row
/// at the bottom of the viewport whenever a track is active and the route
/// isn't in [_hiddenRoutes]. Uses a Column (reserved space) rather than a
/// Stack overlay so screens can never visually hide or overlap the bar.
class GlobalPlayerOverlay extends StatelessWidget {
  const GlobalPlayerOverlay({super.key, required this.child});

  final Widget child;

  static const Set<String> _hiddenRoutes = {
    AppRouter.splash,
    AppRouter.welcome,
    AppRouter.signup,
    AppRouter.verifyEmail,
    AppRouter.createUsername,
    AppRouter.setupAvatar,
    AppRouter.followFavourites,
    AppRouter.congratulations,
    AppRouter.login,
    AppRouter.resetPassword,
    AppRouter.createNewPassword,
    AppRouter.verifyEmailForPasswordReset,
    AppRouter.musicPlayer,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RouteInformation>(
      valueListenable: AppRouter.router.routeInformationProvider,
      builder: (context, info, _) {
        final path = info.uri.path;
        final hide = _hiddenRoutes.contains(path);

        return Material(
          color: AppColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: child),
              if (!hide) const PersistentMiniPlayer(),
            ],
          ),
        );
      },
    );
  }
}
