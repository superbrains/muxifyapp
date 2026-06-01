import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// App logger. In debug builds it logs both via `dart:developer` (structured,
/// visible in the IDE / DevTools) AND via `debugPrint` (visible as `I/flutter`
/// lines in `adb logcat` / `flutter logs`), so field diagnostics are reachable
/// no matter how the developer is watching output. All output is stripped from
/// release builds by the `kDebugMode` guard.
///
/// Every line is tagged `[MUX][LEVEL]` so it can be grepped, e.g.
/// `adb logcat | grep "\[MUX\]"` or search for "Track stream" / "AudioPlayer".
class Logger {
  Logger._();

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: 'Logger.DEBUG',
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
    _print('DEBUG', message, error, stackTrace);
  }

  static void info(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'Logger.INFO', level: 800);
    _print('INFO', message);
  }

  static void warning(String message, [dynamic error]) {
    if (!kDebugMode) return;
    developer.log(message, name: 'Logger.WARNING', level: 900, error: error);
    _print('WARN', message, error);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: 'Logger.ERROR',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    _print('ERROR', message, error, stackTrace);
  }

  static void success(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'Logger.SUCCESS', level: 800);
    _print('OK', message);
  }

  /// Mirrors a log line to stdout so it surfaces as `I/flutter` in logcat.
  static void _print(
    String level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('[MUX][$level] $message');
    if (error != null) debugPrint('[MUX][$level] └─ error: $error');
    if (stackTrace != null) debugPrint('[MUX][$level] └─ $stackTrace');
  }
}
