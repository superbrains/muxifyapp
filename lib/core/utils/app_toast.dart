import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Central toast styling so providers can surface errors without a [BuildContext].
class AppToast {
  AppToast._();

  static Future<void> showError(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  static Future<void> showInfo(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
