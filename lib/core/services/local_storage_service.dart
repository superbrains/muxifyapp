import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricSetupKey = 'biometric_setup';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  static Future<bool> isBiometricSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricSetupKey) ?? false;
  }

  static Future<void> setBiometricSetup(bool setup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricSetupKey, setup);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordKey);
  }

  static Future<void> setUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPasswordKey, password);
  }

  static Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPasswordKey);
  }

  static Future<void> clearBiometricData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_biometricSetupKey);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
