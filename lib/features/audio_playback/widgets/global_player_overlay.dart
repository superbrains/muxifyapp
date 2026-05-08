import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/core/router/app_router.dart';
import 'package:muxify/features/audio_playback/widgets/persistent_mini_player.dart';

/// Wraps the whole app in a Stack so the [PersistentMiniPlayer] survives
/// route changes. Hidden on the full music player and on the auth /
/// onboarding flow.
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
    final path = GoRouterState.of(context).uri.path;
    final hide = _hiddenRoutes.contains(path);

    return Stack(
      children: [
        Positioned.fill(child: child),
        if (!hide)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: const PersistentMiniPlayer(),
            ),
          ),
      ],
    );
  }
}
