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
import 'package:muxify/features/auth/login_screen.dart';
import 'package:muxify/features/auth/reset_password_screen.dart';
import 'package:muxify/features/auth/create_new_password_screen.dart';
import 'package:muxify/features/auth/verify_email_for_password_reset_screen.dart';
import 'package:muxify/features/home/screens/home_screen.dart';
import 'package:muxify/features/statistics/screens/statistics_screen.dart';
import 'package:muxify/features/featured_playlist/screens/featured_playlist_screen.dart';
import 'package:muxify/features/trending_videos/screens/trending_videos_screen.dart';
import 'package:muxify/features/artist_profile/screens/artist_profile_screen.dart';
import 'package:muxify/features/video_player/screens/video_player_screen.dart';
import 'package:muxify/features/artist_profile/screens/new_release_screen.dart';
import 'package:muxify/features/artist_profile/screens/all_videos_screen.dart';
import 'package:muxify/features/artist_profile/screens/albums_screen.dart';
import 'package:muxify/features/artist_profile/screens/singles_screen.dart';
import 'package:muxify/features/artist_profile/screens/album_details_screen.dart';
import 'package:muxify/features/music_player/screens/music_player_screen.dart';
import 'package:muxify/features/music_player/screens/get_coins_screen.dart';
import 'package:muxify/features/fan_profile/screens/fan_profile_screen.dart';

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
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String createNewPassword = '/create-new-password';
  static const String verifyEmailForPasswordReset =
      '/verify-email-password-reset';
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String trending = '/trending';
  static const String trendingVideos = '/trending-videos';
  static const String videoPlayer = '/video-player';
  static const String artistProfile = '/artist-profile';
  static const String newRelease = '/new-release';
  static const String allVideos = '/all-videos';
  static const String albums = '/albums';
  static const String singles = '/singles';
  static const String albumDetails = '/album-details';
  static const String musicPlayer = '/music-player';
  static const String getCoins = '/get-coins';
  static const String fanProfile = '/fan-profile';

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
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: resetPassword,
        name: 'reset-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: createNewPassword,
        name: 'create-new-password',
        pageBuilder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? 'johndoe@gmail.com';
          return MaterialPage(
            key: state.pageKey,
            child: CreateNewPasswordScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: verifyEmailForPasswordReset,
        name: 'verify-email-password-reset',
        pageBuilder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? 'johndoe@gmail.com';
          return MaterialPage(
            key: state.pageKey,
            child: VerifyEmailForPasswordResetScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const HomeScreen()),
      ),
      GoRoute(
        path: statistics,
        name: 'statistics',
        pageBuilder: (context, state) {
          final mediaType = state.uri.queryParameters['mediaType'];
          return MaterialPage(
            key: state.pageKey,
            child: StatisticsScreen(initialMediaType: mediaType),
          );
        },
      ),
      GoRoute(
        path: trending,
        name: 'trending',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FeaturedPlaylistScreen(),
        ),
      ),
      GoRoute(
        path: trendingVideos,
        name: 'trending-videos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TrendingVideosScreen(),
        ),
      ),
      GoRoute(
        path: videoPlayer,
        name: 'video-player',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const VideoPlayerScreen()),
      ),
      GoRoute(
        path: artistProfile,
        name: 'artist-profile',
        pageBuilder: (context, state) {
          final artistId = state.uri.queryParameters['artistId'];
          final artistName = state.uri.queryParameters['artistName'];
          final coverImageUrl = state.uri.queryParameters['coverImageUrl'];
          final followers = state.uri.queryParameters['followers'];
          final mediaType = state.uri.queryParameters['mediaType'];

          return MaterialPage(
            key: state.pageKey,
            child: ArtistProfileScreen(
              artistId: artistId,
              artistName: artistName,
              coverImageUrl: coverImageUrl,
              followers: followers,
              mediaType: mediaType,
            ),
          );
        },
      ),
      GoRoute(
        path: newRelease,
        name: 'new-release',
        pageBuilder: (context, state) {
          final mediaType = state.uri.queryParameters['mediaType'];

          return MaterialPage(
            key: state.pageKey,
            child: NewReleaseScreen(mediaType: mediaType),
          );
        },
      ),
      GoRoute(
        path: allVideos,
        name: 'all-videos',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AllVideosScreen()),
      ),
      GoRoute(
        path: albums,
        name: 'albums',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AlbumsScreen()),
      ),
      GoRoute(
        path: singles,
        name: 'singles',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SinglesScreen()),
      ),
      GoRoute(
        path: albumDetails,
        name: 'album-details',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AlbumDetailsScreen()),
      ),
      GoRoute(
        path: musicPlayer,
        name: 'music-player',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MusicPlayerScreen()),
      ),
      GoRoute(
        path: getCoins,
        name: 'get-coins',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const GetCoinsScreen()),
      ),
      GoRoute(
        path: fanProfile,
        name: 'fan-profile',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const FanProfileScreen()),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
