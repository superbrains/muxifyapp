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

  static String artistFollowPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/follow';

  static String artistNewReleasesPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/new-releases';

  static String artistTracksPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/tracks';

  static String artistAlbumsPath(String artistId) =>
      '$apiV1Prefix/artists/${Uri.encodeComponent(artistId.trim())}/albums';

  static String trackStreamPath(String trackId) =>
      '$apiV1Prefix/content/tracks/${Uri.encodeComponent(trackId.trim())}/stream';

  static String trackUnlockPath(String trackId) =>
      '$apiV1Prefix/content/tracks/${Uri.encodeComponent(trackId.trim())}/unlock';

  static const String giftTypesPath = '$apiV1Prefix/gifts/types';

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
