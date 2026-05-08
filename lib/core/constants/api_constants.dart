class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://ca-muxify-backend-dev.whiterock-80a08890.southafricanorth.azurecontainerapps.io';

  /// Optional override via `--dart-define=API_BASE=...`.
  static String get resolvedBaseUrl {
    const apiBase = String.fromEnvironment('API_BASE');
    if (apiBase.trim().isNotEmpty) return apiBase.trim();
    return baseUrl;
  }

  /// On by default while payment integration is pending. When true, the
  /// unlock & gift confirm UIs hide the "insufficient coins" error and
  /// "Get Coins" CTA, and call the unlock/gift endpoints directly. The
  /// backend must also have `Features:DemoMode=true` for these calls to
  /// succeed (also defaulted to true). Override via
  /// `--dart-define=DEMO_MODE=false` once real payments ship.
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  static String resolvePublicUrl(String pathOrUrl) {
    final t = pathOrUrl.trim();
    if (t.isEmpty) return t;
    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return t;
    }
    final path = t.startsWith('/') ? t : '/$t';
    return Uri.parse(resolvedBaseUrl).resolve(path).toString();
  }

  // --- Local Docker / emulator (`http://10.0.2.2:5116`, etc.) — disabled ---
  // import 'package:flutter/foundation.dart';
  //
  // static const int localBackendDevPort = 5116;
  //
  // static String get localMachineBackendHttpBaseUrl {
  //   const hostFromDefine = String.fromEnvironment('LAN_HOST');
  //   final fromDefine = hostFromDefine.trim();
  //   late final String host;
  //   if (fromDefine.isNotEmpty) {
  //     host = fromDefine;
  //   } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //     const adbReverse = bool.fromEnvironment(
  //       'ADB_REVERSE',
  //       defaultValue: false,
  //     );
  //     if (adbReverse) {
  //       host = '127.0.0.1';
  //     } else {
  //       host = '10.0.2.2';
  //     }
  //   } else {
  //     host = '127.0.0.1';
  //   }
  //   return 'http://$host:$localBackendDevPort';
  // }
  //
  // In [resolvedBaseUrl]: after `API_BASE` check, optionally restore:
  //   const useLocalExplicit = bool.fromEnvironment('USE_LOCAL_BACKEND', defaultValue: false);
  //   const forceProductionApi = bool.fromEnvironment('FORCE_PRODUCTION_API', defaultValue: false);
  //   final preferLocalDocker = useLocalExplicit || (!kReleaseMode && !forceProductionApi);
  //   if (preferLocalDocker) return localMachineBackendHttpBaseUrl;

  static const String devBaseUrl = baseUrl;
  static const String stagingBaseUrl = 'https://staging.api.muxify.com';

  static const String apiV1Prefix = '/api/v1';
  static const String authPrefix = '$apiV1Prefix/auth';
  static const String loginPath = '$authPrefix/login';
  static const String registerPath = '$authPrefix/register';
  static const String logoutPath = '$authPrefix/logout';
  static const String refreshTokenPath = '$authPrefix/refresh';
  static const String verifyEmailPath = '$authPrefix/verify-email';
  static const String forgotPasswordPath = '$authPrefix/forgot-password';
  static const String resetPasswordPath = '$authPrefix/reset-password';

  static const String onboardingPrefix = '$apiV1Prefix/onboarding';
  static const String checkUsernamePath = '$onboardingPrefix/check-username';
  static const String setUsernamePath = '$onboardingPrefix/set-username';
  static const String presetAvatarsPath = '$onboardingPrefix/avatars';
  static const String setAvatarPath = '$onboardingPrefix/set-avatar';
  static const String suggestedArtistsPath =
      '$onboardingPrefix/suggested-artists';
  static const String followArtistsPath = '$onboardingPrefix/follow-artists';
  static const String completeOnboardingPath = '$onboardingPrefix/complete';

  static String artistProfilePath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}';

  static String artistFollowPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/follow';

  static String artistNewReleasesPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/new-releases';

  static String artistTracksPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/tracks';

  static String artistAlbumsPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/albums';

  static String artistVideosPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/videos';

  static const String trendingArtistsPath =
      '$apiV1Prefix/discover/trending/artists';

  // Home Music tab feed endpoints (all require auth).
  static const String feedHomePath = '$apiV1Prefix/feed/home';
  static const String feedRecentlyPlayedPath = '$apiV1Prefix/feed/recently-played';
  static const String feedTrendingTracksPath = '$apiV1Prefix/feed/trending-tracks';
  static const String feedHotReleasesPath = '$apiV1Prefix/feed/hot-releases';
  static const String feedTopChartsPath = '$apiV1Prefix/feed/top-charts';
  static const String feedNewReleasesPath = '$apiV1Prefix/feed/new-releases';
  static const String feedFeaturedPlaylistsPath =
      '$apiV1Prefix/feed/playlists/featured';
  static const String feedFromFollowingPath = '$apiV1Prefix/feed/from-following';
  static const String feedSpotlightPath = '$apiV1Prefix/feed/spotlight';
  static const String feedMostGiftedPath = '$apiV1Prefix/feed/most-gifted';
  static const String feedTopGiversPath = '$apiV1Prefix/feed/top-givers';

  // Home Videos tab feed endpoints (all require auth).
  static const String feedTrendingVideosPath =
      '$apiV1Prefix/feed/videos/trending';
  static const String feedHotReleaseVideosPath =
      '$apiV1Prefix/feed/videos/hot-releases';
  static const String feedTopChartVideosPath =
      '$apiV1Prefix/feed/videos/top-charts';
  static const String feedNewReleaseVideosPath =
      '$apiV1Prefix/feed/videos/new-releases';
  static const String feedVideosFromFollowingPath =
      '$apiV1Prefix/feed/videos/from-following';
  static const String feedVideoSpotlightPath =
      '$apiV1Prefix/feed/videos/spotlight';
  static const String feedMostGiftedVideosPath =
      '$apiV1Prefix/feed/videos/most-gifted';

  static String trackStreamPath(String trackId) =>
      '$apiV1Prefix/content/tracks/${Uri.encodeComponent(trackId.trim())}/stream';

  static String trackUnlockPath(String trackId) =>
      '$apiV1Prefix/content/tracks/${Uri.encodeComponent(trackId.trim())}/unlock';

  static String videoUnlockPath(String videoId) =>
      '$apiV1Prefix/content/videos/${Uri.encodeComponent(videoId.trim())}/unlock';

  static String videoStreamPath(String videoId) =>
      '$apiV1Prefix/content/videos/${Uri.encodeComponent(videoId.trim())}/stream';

  static String videoRecordPlayPath(String videoId) =>
      '$apiV1Prefix/content/videos/${Uri.encodeComponent(videoId.trim())}/play';

  static const String giftTypesPath = '$apiV1Prefix/gifts/types';
  static const String giftSendPath = '$apiV1Prefix/gifts/send';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';

  static const int statusOk = 200;
  static const int statusNoContent = 204;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
