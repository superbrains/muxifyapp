import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/network/api_client.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/logger.dart';

/// Central HTTP entry point: timeouts, transport errors, status codes, and JSON parsing.
/// Features use repositories; repositories call this class.
class ApiRequester {
  ApiRequester({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Serialized so parallel 401s don’t hammer `/auth/refresh`.
  Future<bool>? _refreshInFlight;

  Future<Map<String, String>> _authHeadersIfNeeded(bool authenticate) async {
    if (!authenticate) return {};
    final token = await LocalStorageService.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw ApiRequestException(
        'Please sign in again.',
        statusCode: ApiConstants.statusUnauthorized,
      );
    }
    return {
      ApiConstants.authorization: '${ApiConstants.bearer} ${token.trim()}',
    };
  }

  Future<http.Response> _guardNetwork(
    Future<http.Response> Function() send,
  ) async {
    try {
      return await send();
    } on TimeoutException catch (e, st) {
      Logger.error('API timeout', e, st);
      throw ApiRequestException(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException catch (e, st) {
      Logger.error('API socket error', e, st);
      throw ApiRequestException(
        'No network connection. Check Wi‑Fi or mobile data.',
      );
    } on http.ClientException catch (e, st) {
      Logger.error('API client error', e, st);
      throw ApiRequestException(
        'Unable to reach the server. Check your connection.',
      );
    } catch (e, st) {
      Logger.error('API request failed', e, st);
      throw ApiRequestException(
        'Unable to reach the server. Check your connection.',
      );
    }
  }

  /// Exchanges refresh token for new JWT pair (`POST /auth/refresh`).
  Future<bool> _tryRefreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    Future<bool> runner() async {
      final refresh = await LocalStorageService.getRefreshToken();
      if (refresh == null || refresh.trim().isEmpty) return false;

      http.Response resp;
      try {
        resp = await _client.post(
          ApiConstants.refreshTokenPath,
          body: {'refreshToken': refresh.trim()},
        );
      } catch (_) {
        return false;
      }

      if (resp.statusCode != ApiConstants.statusOk) return false;

      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is! Map<String, dynamic>) return false;
        final access = decoded['token'] as String?;
        final nextRefresh = decoded['refreshToken'] as String?;
        if (access == null ||
            access.trim().isEmpty ||
            nextRefresh == null ||
            nextRefresh.trim().isEmpty) {
          return false;
        }
        await LocalStorageService.setAccessToken(access.trim());
        await LocalStorageService.setRefreshToken(nextRefresh.trim());
        return true;
      } catch (_) {
        return false;
      }
    }

    final done = runner();
    _refreshInFlight = done;
    try {
      return await done;
    } finally {
      if (identical(_refreshInFlight, done)) _refreshInFlight = null;
    }
  }

  /// POST JSON body; parse [successStatus] response as JSON object into [T].
  ///
  /// [extraHeaders] are merged on top of the auth headers — used for things
  /// like `Idempotency-Key` on payment-initiation calls.
  Future<T> postJson<T>(
    String path,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> json) fromJson, {
    int successStatus = ApiConstants.statusOk,
    bool authenticate = false,
    Map<String, String>? extraHeaders,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    final merged = <String, String>{...authHeaders, ...?extraHeaders};
    http.Response response = await _guardNetwork(
      () => _client.post(
        path,
        body: body,
        headers: merged.isEmpty ? null : merged,
      ),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      final merged2 = <String, String>{...h2, ...?extraHeaders};
      response = await _guardNetwork(
        () => _client.post(path, body: body, headers: merged2.isEmpty ? null : merged2),
      );
    }

    if (response.statusCode == successStatus) {
      return _decodeJsonObject(response, fromJson);
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// POST; success when status is [successStatus] (default 204 No Content).
  ///
  /// Some servers may respond with **200** and an empty body; set [alsoAcceptStatuses]
  Future<void> postNoContent(
    String path,
    Map<String, dynamic>? body, {
    int successStatus = ApiConstants.statusNoContent,
    Iterable<int>? alsoAcceptStatuses,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    http.Response response = await _guardNetwork(
      () => _client.post(
        path,
        body: body,
        headers: authHeaders.isEmpty ? null : authHeaders,
      ),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      response = await _guardNetwork(
        () => _client.post(path, body: body, headers: h2.isEmpty ? null : h2),
      );
    }

    final acceptable = <int>{successStatus, ...?alsoAcceptStatuses};
    if (acceptable.contains(response.statusCode)) {
      return;
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// `multipart/form-data` POST; parses a JSON **object** on success.
  ///
  /// Does **not** re-send the multipart body after refreshing tokens on 401
  /// (multipart streams aren’t rewindable).
  Future<T> postMultipartJson<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    int successStatus = ApiConstants.statusOk,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    final response = await _guardNetwork(
      () => _client.postMultipart(
        path,
        fields: fields,
        files: files,
        headers: authHeaders.isEmpty ? null : authHeaders,
      ),
    );

    if (response.statusCode == successStatus) {
      return _decodeJsonObject(response, fromJson);
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// GET; parse [successStatus] response as JSON object into [T].
  Future<T> getJson<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, dynamic>? queryParameters,
    int successStatus = ApiConstants.statusOk,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    http.Response response = await _guardNetwork(
      () => _client.get(
        path,
        queryParameters: queryParameters,
        headers: authHeaders.isEmpty ? null : authHeaders,
      ),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      response = await _guardNetwork(
        () => _client.get(
          path,
          queryParameters: queryParameters,
          headers: h2.isEmpty ? null : h2,
        ),
      );
    }

    if (response.statusCode == successStatus) {
      return _decodeJsonObject(response, fromJson);
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// GET JSON **array**; maps each element with [itemFromJson].
  Future<List<T>> getJsonList<T>(
    String path,
    T Function(Map<String, dynamic> json) itemFromJson, {
    Map<String, dynamic>? queryParameters,
    int successStatus = ApiConstants.statusOk,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    http.Response response = await _guardNetwork(
      () => _client.get(
        path,
        queryParameters: queryParameters,
        headers: authHeaders.isEmpty ? null : authHeaders,
      ),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      response = await _guardNetwork(
        () => _client.get(
          path,
          queryParameters: queryParameters,
          headers: h2.isEmpty ? null : h2,
        ),
      );
    }

    if (response.statusCode == successStatus) {
      return _decodeJsonList(response, itemFromJson);
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// DELETE; success when status is one of [successStatus] or [alsoAcceptStatuses].
  /// Use this for endpoints that respond 204 No Content.
  Future<void> deleteNoContent(
    String path, {
    int successStatus = ApiConstants.statusNoContent,
    Iterable<int>? alsoAcceptStatuses,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    http.Response response = await _guardNetwork(
      () => _client.delete(path, headers: authHeaders.isEmpty ? null : authHeaders),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      response = await _guardNetwork(
        () => _client.delete(path, headers: h2.isEmpty ? null : h2),
      );
    }

    final acceptable = <int>{successStatus, ...?alsoAcceptStatuses};
    if (acceptable.contains(response.statusCode)) {
      return;
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  /// DELETE; parse [successStatus] response as JSON object into [T].
  Future<T> deleteJson<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson, {
    int successStatus = ApiConstants.statusOk,
    bool authenticate = false,
  }) async {
    final authHeaders = await _authHeadersIfNeeded(authenticate);
    http.Response response = await _guardNetwork(
      () => _client.delete(
        path,
        headers: authHeaders.isEmpty ? null : authHeaders,
      ),
    );

    if (authenticate &&
        response.statusCode == ApiConstants.statusUnauthorized &&
        await _tryRefreshAccessToken()) {
      final h2 = await _authHeadersIfNeeded(true);
      response = await _guardNetwork(
        () => _client.delete(path, headers: h2.isEmpty ? null : h2),
      );
    }

    if (response.statusCode == successStatus) {
      return _decodeJsonObject(response, fromJson);
    }

    throw ApiRequestException(
      _messageFromErrorBody(
        response.body,
        response.statusCode,
        authenticatedCaller: authenticate,
      ),
      statusCode: response.statusCode,
    );
  }

  List<T> _decodeJsonList<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final raw = response.body.trim();
    if (raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw ApiRequestException('Unexpected response format from server.');
      }

      final out = <T>[];
      for (final item in decoded) {
        if (item is! Map) {
          throw ApiRequestException('Unexpected response format from server.');
        }
        out.add(itemFromJson(Map<String, dynamic>.from(item)));
      }
      return out;
    } on ApiRequestException {
      rethrow;
    } on FormatException catch (e, st) {
      Logger.error('JSON parse error', e, st);
      throw ApiRequestException('Invalid response from server.');
    } catch (e, st) {
      Logger.error('Response mapping error', e, st);
      throw ApiRequestException('Invalid response from server.');
    }
  }

  T _decodeJsonObject<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.body.isEmpty) {
      throw ApiRequestException('Empty response from server.');
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiRequestException('Unexpected response format from server.');
      }
      return fromJson(decoded);
    } on ApiRequestException {
      rethrow;
    } on FormatException catch (e, st) {
      Logger.error('JSON parse error', e, st);
      throw ApiRequestException('Invalid response from server.');
    } catch (e, st) {
      Logger.error('Response mapping error', e, st);
      throw ApiRequestException('Invalid response from server.');
    }
  }

  static String _messageFromErrorBody(
    String body,
    int statusCode, {
    bool authenticatedCaller = false,
  }) {
    if (authenticatedCaller && statusCode == ApiConstants.statusUnauthorized) {
      return 'Your session expired. Please sign in again.';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String && err.trim().isNotEmpty) return err.trim();
      }
    } catch (_) {}

    switch (statusCode) {
      case ApiConstants.statusUnauthorized:
        return 'Invalid email or password.';
      case ApiConstants.statusForbidden:
        return 'You do not have permission to perform this action.';
      case ApiConstants.statusNotFound:
        return 'The requested resource was not found.';
      case ApiConstants.statusBadRequest:
        break;
      case 409:
        return 'This resource already exists.';
      case 422:
        return 'Validation failed. Check your input.';
      default:
        if (statusCode >= 500) {
          return 'Server error. Try again later.';
        }
    }

    try {
      final map = jsonDecode(body);
      if (map is Map<String, dynamic>) {
        final errors = map['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final list = errors[firstKey];
          if (list is List && list.isNotEmpty && list.first is String) {
            return list.first as String;
          }
        }

        final detail = map['detail'];
        if (detail is String && detail.isNotEmpty) return detail;

        final title = map['title'];
        if (title is String && title.isNotEmpty) return title;
      }
    } catch (_) {
      /* use fallback */
    }

    final trimmed = body.trim();
    return trimmed.isEmpty ? 'Request failed ($statusCode)' : trimmed;
  }
}
