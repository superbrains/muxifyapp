import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/utils/logger.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({this.baseUrl = ApiConstants.baseUrl, Map<String, String>? headers})
    : defaultHeaders = {
        ApiConstants.contentType: ApiConstants.applicationJson,
        ApiConstants.accept: ApiConstants.applicationJson,
        ...?headers,
      };

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final mergedHeaders = {...defaultHeaders, ...?headers};

      Logger.debug('GET Request: $uri');

      final response = await http
          .get(uri, headers: mergedHeaders)
          .timeout(ApiConstants.receiveTimeout);

      _logResponse(response);
      return response;
    } catch (e, stackTrace) {
      Logger.error('GET request failed', e, stackTrace);
      rethrow;
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      Logger.debug('POST Request: $uri');
      Logger.debug('Body: $jsonBody');

      final response = await http
          .post(uri, headers: mergedHeaders, body: jsonBody)
          .timeout(ApiConstants.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e, stackTrace) {
      Logger.error('POST request failed', e, stackTrace);
      rethrow;
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      Logger.debug('PUT Request: $uri');
      Logger.debug('Body: $jsonBody');

      final response = await http
          .put(uri, headers: mergedHeaders, body: jsonBody)
          .timeout(ApiConstants.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e, stackTrace) {
      Logger.error('PUT request failed', e, stackTrace);
      rethrow;
    }
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};
      final jsonBody = body != null ? jsonEncode(body) : null;

      Logger.debug('PATCH Request: $uri');
      Logger.debug('Body: $jsonBody');

      final response = await http
          .patch(uri, headers: mergedHeaders, body: jsonBody)
          .timeout(ApiConstants.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e, stackTrace) {
      Logger.error('PATCH request failed', e, stackTrace);
      rethrow;
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final mergedHeaders = {...defaultHeaders, ...?headers};

      Logger.debug('DELETE Request: $uri');

      final response = await http
          .delete(uri, headers: mergedHeaders)
          .timeout(ApiConstants.receiveTimeout);

      _logResponse(response);
      return response;
    } catch (e, stackTrace) {
      Logger.error('DELETE request failed', e, stackTrace);
      rethrow;
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    return uri;
  }

  void _logResponse(http.Response response) {
    Logger.debug('Response Status: ${response.statusCode}');
    Logger.debug('Response Body: ${response.body}');
  }

  static void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      switch (response.statusCode) {
        case ApiConstants.statusBadRequest:
          throw Exception('Bad Request: ${response.body}');
        case ApiConstants.statusUnauthorized:
          throw Exception('Unauthorized: Please login again');
        case ApiConstants.statusForbidden:
          throw Exception('Forbidden: Access denied');
        case ApiConstants.statusNotFound:
          throw Exception('Not Found: ${response.body}');
        case ApiConstants.statusInternalServerError:
          throw Exception('Server Error: Please try again later');
        default:
          throw Exception('Error: ${response.statusCode}');
      }
    }
  }

  static dynamic parseResponse(http.Response response) {
    try {
      handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      Logger.error('Failed to parse response', e);
      rethrow;
    }
  }
}
