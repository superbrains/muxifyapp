import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:muxify/core/services/local_storage_service.dart';

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool isEnabled = await LocalStorageService.isBiometricEnabled();
      return isAvailable && isDeviceSupported && isEnabled;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login to Muxify',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setupBiometric() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!isDeviceSupported || !canCheckBiometrics) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Setup biometric authentication for Muxify',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await LocalStorageService.setBiometricEnabled(true);
        await LocalStorageService.setBiometricSetup(true);
      }

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  static Future<void> disableBiometric() async {
    await LocalStorageService.setBiometricEnabled(false);
  }
}
