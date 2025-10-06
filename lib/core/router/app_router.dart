import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muxify/features/splash/splash_screen.dart';
import 'package:muxify/features/welcome/welcome_screen.dart';
import 'package:muxify/features/auth/signup_screen.dart';
import 'package:muxify/features/auth/verify_email_screen.dart';
import 'package:muxify/features/auth/create_username_screen.dart';
import 'package:muxify/features/auth/setup_avatar_screen.dart';
import 'package:muxify/features/auth/follow_favourites_screen.dart';
import 'package:muxify/features/auth/congratulations_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String createUsername = '/create-username';
  static const String setupAvatar = '/setup-avatar';
  static const String followFavourites = '/follow-favourites';
  static const String congratulations = '/congratulations';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: welcome,
        name: 'welcome',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const WelcomeScreen()),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignupScreen()),
      ),
      GoRoute(
        path: verifyEmail,
        name: 'verify-email',
        pageBuilder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? 'user@example.com';
          return MaterialPage(
            key: state.pageKey,
            child: VerifyEmailScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: createUsername,
        name: 'create-username',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CreateUsernameScreen(),
        ),
      ),
      GoRoute(
        path: setupAvatar,
        name: 'setup-avatar',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SetupAvatarScreen()),
      ),
      GoRoute(
        path: followFavourites,
        name: 'follow-favourites',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FollowFavouritesScreen(),
        ),
      ),
      GoRoute(
        path: congratulations,
        name: 'congratulations',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CongratulationsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
