/// Thrown by [ApiRequester] (and repositories) for any failed or invalid API outcome.
class ApiRequestException implements Exception {
  ApiRequestException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
