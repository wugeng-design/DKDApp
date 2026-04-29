import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0,
    );
  }

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFFFF5252),
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }

  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }

  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFF2196F3),
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }
}