import 'package:shared_preferences/shared_preferences.dart';
import 'package:muxify/core/utils/logger.dart';


class StorageService {
  static SharedPreferences? _preferences;


  static Future<void> init() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      Logger.success('Storage service initialized');
    } catch (e) {
      Logger.error('Failed to initialize storage service', e);
    }
  }


  static Future<bool> setString(String key, String value) async {
    try {
      return await _preferences?.setString(key, value) ?? false;
    } catch (e) {
      Logger.error('Error saving string to storage', e);
      return false;
    }
  }


  static String? getString(String key) {
    try {
      return _preferences?.getString(key);
    } catch (e) {
      Logger.error('Error getting string from storage', e);
      return null;
    }
  }


  static Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences?.setInt(key, value) ?? false;
    } catch (e) {
      Logger.error('Error saving int to storage', e);
      return false;
    }
  }


  static int? getInt(String key) {
    try {
      return _preferences?.getInt(key);
    } catch (e) {
      Logger.error('Error getting int from storage', e);
      return null;
    }
  }


  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences?.setBool(key, value) ?? false;
    } catch (e) {
      Logger.error('Error saving bool to storage', e);
      return false;
    }
  }


  static bool? getBool(String key) {
    try {
      return _preferences?.getBool(key);
    } catch (e) {
      Logger.error('Error getting bool from storage', e);
      return null;
    }
  }


  static Future<bool> setDouble(String key, double value) async {
    try {
      return await _preferences?.setDouble(key, value) ?? false;
    } catch (e) {
      Logger.error('Error saving double to storage', e);
      return false;
    }
  }


  static double? getDouble(String key) {
    try {
      return _preferences?.getDouble(key);
    } catch (e) {
      Logger.error('Error getting double from storage', e);
      return null;
    }
  }


  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _preferences?.setStringList(key, value) ?? false;
    } catch (e) {
      Logger.error('Error saving string list to storage', e);
      return false;
    }
  }


  static List<String>? getStringList(String key) {
    try {
      return _preferences?.getStringList(key);
    } catch (e) {
      Logger.error('Error getting string list from storage', e);
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      return await _preferences?.remove(key) ?? false;
    } catch (e) {
      Logger.error('Error removing key from storage', e);
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      return await _preferences?.clear() ?? false;
    } catch (e) {
      Logger.error('Error clearing storage', e);
      return false;
    }
  }

  static bool containsKey(String key) {
    try {
      return _preferences?.containsKey(key) ?? false;
    } catch (e) {
      Logger.error('Error checking key in storage', e);
      return false;
    }
  }

  static Set<String>? getKeys() {
    try {
      return _preferences?.getKeys();
    } catch (e) {
      Logger.error('Error getting keys from storage', e);
      return null;
    }
  }
}

