import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:muxify/core/models/auth/auth_login_result.dart';
import 'package:muxify/core/network/api_exceptions.dart';
import 'package:muxify/core/services/local_storage_service.dart';
import 'package:muxify/core/utils/app_toast.dart';
import 'package:muxify/features/auth/data/auth_repository.dart';

enum AuthLoginState { idle, loading }

enum AuthSignupState { idle, loading }

enum AuthVerifyEmailState { idle, loading }

enum AuthForgotPasswordState { idle, loading }

enum AuthResetPasswordState { idle, loading }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  AuthLoginState _loginState = AuthLoginState.idle;
  AuthSignupState _signupState = AuthSignupState.idle;
  AuthVerifyEmailState _verifyEmailState = AuthVerifyEmailState.idle;
  AuthForgotPasswordState _forgotPasswordState = AuthForgotPasswordState.idle;
  AuthResetPasswordState _resetPasswordState = AuthResetPasswordState.idle;

  AuthLoginState get loginState => _loginState;

  bool get isLoginLoading => _loginState == AuthLoginState.loading;

  bool get isSignupLoading => _signupState == AuthSignupState.loading;

  bool get isVerifyEmailLoading =>
      _verifyEmailState == AuthVerifyEmailState.loading;

  bool get isForgotPasswordLoading =>
      _forgotPasswordState == AuthForgotPasswordState.loading;

  bool get isResetPasswordSubmitting =>
      _resetPasswordState == AuthResetPasswordState.loading;

  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();

    if (trimmed.isEmpty || password.isEmpty) {
      await AppToast.showError('Enter your email and password.');
      return false;
    }

    _loginState = AuthLoginState.loading;
    notifyListeners();

    try {
      final result = await _repository.login(
        email: trimmed,
        password: password,
      );
      if (result.token.trim().isEmpty || result.refreshToken.trim().isEmpty) {
        await AppToast.showError('Invalid session from server.');
        _loginState = AuthLoginState.idle;
        notifyListeners();
        return false;
      }
      if (result.user.id.trim().isEmpty) {
        await AppToast.showError('Invalid user data from server.');
        _loginState = AuthLoginState.idle;
        notifyListeners();
        return false;
      }
      await _persistAuthSession(
        result: result,
        email: trimmed,
        password: password,
      );
      _loginState = AuthLoginState.idle;
      notifyListeners();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      _loginState = AuthLoginState.idle;
      notifyListeners();
      return false;
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
      _loginState = AuthLoginState.idle;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      await AppToast.showError('Enter your email and password.');
      return false;
    }

    _signupState = AuthSignupState.loading;
    notifyListeners();

    try {
      final result = await _repository.register(
        email: trimmedEmail,
        password: password,
        name: name,
        phone: phone,
      );
      if (result.token.trim().isEmpty || result.refreshToken.trim().isEmpty) {
        await AppToast.showError('Invalid session from server.');
        _signupState = AuthSignupState.idle;
        notifyListeners();
        return false;
      }
      if (result.user.id.trim().isEmpty) {
        await AppToast.showError('Invalid user data from server.');
        _signupState = AuthSignupState.idle;
        notifyListeners();
        return false;
      }
      await _persistAuthSession(
        result: result,
        email: trimmedEmail,
        password: password,
      );
      _signupState = AuthSignupState.idle;
      notifyListeners();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      _signupState = AuthSignupState.idle;
      notifyListeners();
      return false;
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
      _signupState = AuthSignupState.idle;
      notifyListeners();
      return false;
    }
  }

  /// `POST /api/v1/auth/forgot-password` — server always responds 200 (no email enumeration).
  Future<bool> requestPasswordReset(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) {
      await AppToast.showError('Enter your email address.');
      return false;
    }

    _forgotPasswordState = AuthForgotPasswordState.loading;
    notifyListeners();

    try {
      await _repository.forgotPassword(email: trimmed);
      await AppToast.showInfo(
        'If this email is registered, you will receive reset instructions.',
      );
      _forgotPasswordState = AuthForgotPasswordState.idle;
      notifyListeners();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      _forgotPasswordState = AuthForgotPasswordState.idle;
      notifyListeners();
      return false;
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
      _forgotPasswordState = AuthForgotPasswordState.idle;
      notifyListeners();
      return false;
    }
  }

  /// `POST /api/v1/auth/reset-password` with token from the reset email.
  Future<bool> submitPasswordReset({
    required String token,
    required String password,
  }) async {
    final t = token.trim();
    if (t.isEmpty || password.isEmpty) {
      await AppToast.showError('Enter the reset token and a new password.');
      return false;
    }

    _resetPasswordState = AuthResetPasswordState.loading;
    notifyListeners();

    try {
      await _repository.resetPassword(token: t, password: password);
      await AppToast.showInfo('Password reset successfully');
      _resetPasswordState = AuthResetPasswordState.idle;
      notifyListeners();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      _resetPasswordState = AuthResetPasswordState.idle;
      notifyListeners();
      return false;
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
      _resetPasswordState = AuthResetPasswordState.idle;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      await AppToast.showError('Enter the verification code.');
      return false;
    }

    _verifyEmailState = AuthVerifyEmailState.loading;
    notifyListeners();

    try {
      await _repository.verifyEmail(code: trimmed);
      await _persistEmailVerifiedUser();
      await AppToast.showInfo('Email verified successfully');
      _verifyEmailState = AuthVerifyEmailState.idle;
      notifyListeners();
      return true;
    } on ApiRequestException catch (e) {
      await AppToast.showError(e.message);
      _verifyEmailState = AuthVerifyEmailState.idle;
      notifyListeners();
      return false;
    } catch (_) {
      await AppToast.showError('Something went wrong. Please try again.');
      _verifyEmailState = AuthVerifyEmailState.idle;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStoredAvatarUrl(String resolvedUrl) async {
    final raw = await LocalStorageService.getAuthUserJson();
    final user = AuthUserDto.tryParseStored(raw);
    if (user == null) return;
    final updated = user.copyWith(avatar: resolvedUrl);
    await LocalStorageService.setAuthUserJson(jsonEncode(updated.toJson()));
  }

  Future<void> _persistEmailVerifiedUser() async {
    final raw = await LocalStorageService.getAuthUserJson();
    final user = AuthUserDto.tryParseStored(raw);
    if (user == null) return;
    final updated = user.copyWith(isVerified: true);
    await LocalStorageService.setAuthUserJson(jsonEncode(updated.toJson()));
  }

  /// Call when leaving login flow without completing sign-in so state is predictable.
  void resetLoginPresentationState() {
    if (_loginState != AuthLoginState.idle) {
      _loginState = AuthLoginState.idle;
      notifyListeners();
    }
  }

  void resetSignupPresentationState() {
    if (_signupState != AuthSignupState.idle) {
      _signupState = AuthSignupState.idle;
      notifyListeners();
    }
  }

  /// Persists login/register: email + password (biometric replay), JWT access token,
  /// refresh token, and full [AuthUserDto] JSON via [LocalStorageService].
  Future<void> _persistAuthSession({
    required AuthLoginResult result,
    required String email,
    required String password,
  }) async {
    await LocalStorageService.setUserEmail(email);
    await LocalStorageService.setUserPassword(password);
    await LocalStorageService.setAccessToken(result.token.trim());
    await LocalStorageService.setRefreshToken(result.refreshToken.trim());
    await LocalStorageService.setAuthUserJson(jsonEncode(result.user.toJson()));
  }

  void resetVerifyEmailPresentationState() {
    if (_verifyEmailState != AuthVerifyEmailState.idle) {
      _verifyEmailState = AuthVerifyEmailState.idle;
      notifyListeners();
    }
  }

  void resetForgotPasswordPresentationState() {
    if (_forgotPasswordState != AuthForgotPasswordState.idle) {
      _forgotPasswordState = AuthForgotPasswordState.idle;
      notifyListeners();
    }
  }

  void resetPasswordResetPresentationState() {
    if (_resetPasswordState != AuthResetPasswordState.idle) {
      _resetPasswordState = AuthResetPasswordState.idle;
      notifyListeners();
    }
  }
}
