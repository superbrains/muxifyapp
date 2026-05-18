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
import 'package:muxify/features/home/models/trending_artist.dart';
import 'package:muxify/features/video_player/screens/video_player_screen.dart';
import 'package:muxify/features/artist_profile/screens/new_release_screen.dart';
import 'package:muxify/features/artist_profile/screens/all_videos_screen.dart';
import 'package:muxify/features/artist_profile/screens/albums_screen.dart';
import 'package:muxify/features/artist_profile/screens/singles_screen.dart';
import 'package:muxify/features/artist_profile/screens/album_details_screen.dart';
import 'package:muxify/features/music_player/screens/music_player_screen.dart';
import 'package:muxify/features/music_player/screens/get_coins_screen.dart';
import 'package:muxify/features/fan_profile/screens/fan_profile_screen.dart';
import 'package:muxify/features/profile_menu/screens/about_muxify_screen.dart';
import 'package:muxify/features/profile_menu/screens/account_verification_screen.dart';
import 'package:muxify/features/profile_menu/screens/customer_services_screen.dart';
import 'package:muxify/features/profile_menu/screens/delete_account_screen.dart';
import 'package:muxify/features/profile_menu/screens/faq_screen.dart';
import 'package:muxify/features/profile_menu/screens/legals_screen.dart';
import 'package:muxify/features/profile_menu/screens/pin_settings_screen.dart';
import 'package:muxify/features/profile_menu/screens/privacy_policy_screen.dart';
import 'package:muxify/features/profile_menu/screens/wallet_payment_screen.dart';
import 'package:muxify/features/wallet/screens/payment_status_screen.dart';
import 'package:muxify/features/wallet/services/wallet_api_service.dart';
import 'package:muxify/features/my_music/screens/my_music_screen.dart';
import 'package:muxify/features/my_music/screens/playlist_detail_screen.dart';
import 'package:muxify/features/my_music/screens/playlist_track_picker_screen.dart';

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
  static const String fanProfile = '/fan-profile/:fanId';

  /// Builds a navigable URL for the fan profile of [fanId].
  static String fanProfileFor(String fanId) =>
      '/fan-profile/${Uri.encodeComponent(fanId.trim())}';

  // My Music hub (Library + local playlists).
  static const String myMusic = '/my-music';
  static const String playlistDetail = '/my-music/playlists/:id';
  static const String playlistAddTracks = '/my-music/playlists/:id/add';

  static String playlistDetailPath(String playlistId) =>
      '/my-music/playlists/${Uri.encodeComponent(playlistId.trim())}';

  static String playlistAddTracksPath(String playlistId) =>
      '/my-music/playlists/${Uri.encodeComponent(playlistId.trim())}/add';

  // Fan profile menu sub-pages.
  static const String accountVerification = '/account-verification';
  static const String walletPayment = '/wallet-payment';
  static const String pinSettings = '/pin-settings';
  static const String aboutMuxify = '/about';
  static const String privacyPolicy = '/privacy';
  static const String legals = '/legals';
  static const String customerServices = '/support';
  static const String faq = '/faq';
  static const String deleteAccount = '/delete-account';

  /// Post-initiate wallet flow: WebView for hosted-checkout channels or
  /// virtual-account/USSD details for offline-bank channels. Polls
  /// `/payments/collections/{intentId}` until terminal.
  static const String paymentStatus = '/payment-status';

  /// Live name of the topmost route. The mini-player listens to this so it
  /// can hide itself while `/music-player` is on top, without depending on
  /// each screen to flip a flag in initState/dispose.
  static final ValueNotifier<String?> topRouteName = ValueNotifier<String?>(null);

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    observers: [_MiniPlayerRouteObserver()],
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
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];
          final trimmedToken = token?.trim();
          return MaterialPage(
            key: state.pageKey,
            child: CreateNewPasswordScreen(
              email: email,
              initialToken: (trimmedToken == null || trimmedToken.isEmpty)
                  ? null
                  : trimmedToken,
            ),
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
        pageBuilder: (context, state) {
          final initialTabId = state.uri.queryParameters['tabId'];
          return MaterialPage(
            key: state.pageKey,
            child: FeaturedPlaylistScreen(initialTabId: initialTabId),
          );
        },
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
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return MaterialPage(
            key: state.pageKey,
            child: VideoPlayerScreen(
              videoId: q['videoId'] ?? '',
              title: q['title'] ?? '',
              artistName: q['artistName'] ?? '',
              artistId: q['artistId'],
              thumbnailUrl: q['thumbnailUrl'],
              isUnlocked: q['isUnlocked'] != 'false',
            ),
          );
        },
      ),
      GoRoute(
        path: artistProfile,
        name: 'artist-profile',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final artist = TrendingArtist(
            id: q['artistId'] ?? '',
            name: q['artistName'] ?? 'Artist',
            imageUrl: q['coverImageUrl'],
            followerCount: int.tryParse(q['followerCount'] ?? '') ?? 0,
            isFollowing: q['isFollowing'] == 'true',
            isVerified: q['isVerified'] == 'true',
          );
          final mediaType = q['mediaType'];

          return MaterialPage(
            key: state.pageKey,
            child: ArtistProfileScreen(artist: artist, mediaType: mediaType),
          );
        },
      ),
      GoRoute(
        path: newRelease,
        name: 'new-release',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final mediaType = q['mediaType'];
          final artistId = q['artistId'];
          final artistName = q['artistName'];

          return MaterialPage(
            key: state.pageKey,
            child: NewReleaseScreen(
              mediaType: mediaType,
              artistId: artistId,
              artistName: artistName,
            ),
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
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final artistId = q['artistId'];
          final artistName = q['artistName'];

          return MaterialPage(
            key: state.pageKey,
            child: AlbumsScreen(artistId: artistId, artistName: artistName),
          );
        },
      ),
      GoRoute(
        path: singles,
        name: 'singles',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final artistId = q['artistId'];
          final artistName = q['artistName'];

          return MaterialPage(
            key: state.pageKey,
            child: SinglesScreen(artistId: artistId, artistName: artistName),
          );
        },
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
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return MaterialPage(
            key: state.pageKey,
            child: MusicPlayerScreen(
              trackId: q['trackId'],
              title: q['title'],
              artistName: q['artistName'],
              artistId: q['artistId'],
              albumName: q['albumName'],
              backgroundImageUrl: q['backgroundImageUrl'],
              audioUrl: q['audioUrl'],
              isUnlocked: q['isUnlocked'] == 'true',
            ),
          );
        },
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
        pageBuilder: (context, state) {
          final fanId = state.pathParameters['fanId'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: FanProfileScreen(fanId: fanId),
          );
        },
      ),
      GoRoute(
        path: myMusic,
        name: 'my-music',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MyMusicScreen()),
      ),
      GoRoute(
        path: playlistDetail,
        name: 'playlist-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: PlaylistDetailScreen(playlistId: id),
          );
        },
      ),
      GoRoute(
        path: playlistAddTracks,
        name: 'playlist-add-tracks',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: PlaylistTrackPickerScreen(playlistId: id),
          );
        },
      ),
      GoRoute(
        path: accountVerification,
        name: 'account-verification',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AccountVerificationScreen(),
        ),
      ),
      GoRoute(
        path: walletPayment,
        name: 'wallet-payment',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WalletPaymentScreen(),
        ),
      ),
      GoRoute(
        path: pinSettings,
        name: 'pin-settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PinSettingsScreen(),
        ),
      ),
      GoRoute(
        path: aboutMuxify,
        name: 'about-muxify',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AboutMuxifyScreen(),
        ),
      ),
      GoRoute(
        path: privacyPolicy,
        name: 'privacy-policy',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
        ),
      ),
      GoRoute(
        path: legals,
        name: 'legals',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LegalsScreen()),
      ),
      GoRoute(
        path: customerServices,
        name: 'customer-services',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CustomerServicesScreen(),
        ),
      ),
      GoRoute(
        path: faq,
        name: 'faq',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const FaqScreen()),
      ),
      GoRoute(
        path: deleteAccount,
        name: 'delete-account',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DeleteAccountScreen(),
        ),
      ),
      GoRoute(
        path: paymentStatus,
        name: 'payment-status',
        pageBuilder: (context, state) {
          final intentId = state.uri.queryParameters['intentId'] ?? '';
          final extra = state.extra;
          return MaterialPage(
            key: state.pageKey,
            child: PaymentStatusScreen(
              intentId: intentId,
              initial: extra is InitiateCollectionResult ? extra : null,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}

/// Tracks the topmost route via Navigator lifecycle callbacks. Push/pop/replace
/// all fire here, so [AppRouter.topRouteName] always reflects what's on top.
class _MiniPlayerRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouter.topRouteName.value = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouter.topRouteName.value = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppRouter.topRouteName.value = newRoute?.settings.name;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouter.topRouteName.value = previousRoute?.settings.name;
  }
}
