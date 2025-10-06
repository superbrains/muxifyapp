class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.muxify.com';
  static const String devBaseUrl = 'https://dev.api.muxify.com';
  static const String stagingBaseUrl = 'https://staging.api.muxify.com';

  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
