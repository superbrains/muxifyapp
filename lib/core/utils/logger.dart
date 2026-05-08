import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'Logger.DEBUG',
        level: 500,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'Logger.INFO', level: 800);
    }
  }

  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      developer.log(message, name: 'Logger.WARNING', level: 900, error: error);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'Logger.ERROR',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'Logger.SUCCESS', level: 800);
    }
  }
}
