import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Central toast styling so providers can surface errors without a [BuildContext].
class AppToast {
  AppToast._();

  static Future<void> showError(String message) async {
    // Defensive: a missing/misbehaving Fluttertoast plugin must never throw
    // into callers and break their flow (e.g. blocking a gift send).
    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (_) {
      // Swallow — the toast is best-effort.
    }
  }

  static Future<void> showInfo(String message) async {
    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (_) {
      // Swallow — the toast is best-effort.
    }
  }
}
