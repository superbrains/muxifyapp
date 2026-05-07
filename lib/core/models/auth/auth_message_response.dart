/// `POST /api/v1/auth/verify-email` success body (`message`).
class AuthMessageResponse {
  const AuthMessageResponse({required this.message});

  final String message;

  factory AuthMessageResponse.fromJson(Map<String, dynamic> json) {
    return AuthMessageResponse(
      message: json['message'] as String? ?? '',
    );
  }
}
