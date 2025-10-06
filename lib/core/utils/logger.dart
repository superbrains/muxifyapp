import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🔍 DEBUG: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
      if (error != null) print('Error: $error');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }
}
