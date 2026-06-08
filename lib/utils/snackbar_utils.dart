import 'package:flutter/material.dart';
import 'package:get/get.dart';

// App theme colors from light_theme.dart
const primaryColor = Color(0xFF6366F1); // Indigo-500
const successColor = Color(0xFF10B981); // Emerald-500
const errorColor = Color(0xFFEF4444); // Red-500
const warningColor = Color(0xFFF59E0B); // Amber-500
const infoColor = Color(0xFF3B82F6); // Blue-500

class AppSnackbar {
  static void showSuccess(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: successColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: duration ?? Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: errorColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: duration ?? Duration(seconds: 4),
      icon: Icon(Icons.error, color: Colors.white),
    );
  }

  static void showWarning(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: warningColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: duration ?? Duration(seconds: 3),
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }

  static void showInfo(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: infoColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: duration ?? Duration(seconds: 3),
      icon: Icon(Icons.info, color: Colors.white),
    );
  }

  static void showPrimary(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: primaryColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: duration ?? Duration(seconds: 3),
      icon: Icon(Icons.notifications, color: Colors.white),
    );
  }
}
