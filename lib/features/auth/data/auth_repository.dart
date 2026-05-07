import 'package:muxify/core/constants/api_constants.dart';
import 'package:muxify/core/models/auth/auth_login_result.dart';
import 'package:muxify/core/models/auth/auth_message_response.dart';
import 'package:muxify/core/network/api_requester.dart';

/// Auth API (MVC-style model / data layer). UI talks to [AuthProvider], which uses this class.
class AuthRepository {
  AuthRepository({ApiRequester? requester})
    : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    return _requester.postJson(
      ApiConstants.loginPath,
      {'email': email, 'password': password},
      AuthLoginResult.fromJson,
    );
  }

  /// Mobile (fan): do not send `role` — same contract as Swagger mobile example.
  Future<AuthLoginResult> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim(),
      'password': password,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    };
    return _requester.postJson(
      ApiConstants.registerPath,
      body,
      AuthLoginResult.fromJson,
      successStatus: ApiConstants.statusCreated,
    );
  }

  Future<AuthMessageResponse> verifyEmail({required String code}) {
    return _requester.postJson(
      ApiConstants.verifyEmailPath,
      {'code': code.trim()},
      AuthMessageResponse.fromJson,
    );
  }

  Future<AuthMessageResponse> forgotPassword({required String email}) {
    return _requester.postJson(
      ApiConstants.forgotPasswordPath,
      {'email': email.trim().toLowerCase()},
      AuthMessageResponse.fromJson,
    );
  }

  Future<AuthMessageResponse> resetPassword({
    required String token,
    required String password,
  }) {
    return _requester.postJson(
      ApiConstants.resetPasswordPath,
      {
        'token': token.trim(),
        'password': password,
      },
      AuthMessageResponse.fromJson,
    );
  }
}
