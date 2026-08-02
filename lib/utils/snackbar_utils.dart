import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

// App theme colors from light_theme.dart
const primaryColor = Color(0xFF6366F1); // Indigo-500
const successColor = Color(0xFF10B981); // Emerald-500
const errorColor = Color(0xFFEF4444); // Red-500
const warningColor = Color(0xFFF59E0B); // Amber-500
const infoColor = Color(0xFF3B82F6); // Blue-500

enum _SnackbarKind { success, error, warning, info, primary }

class AppSnackbar {
  static void _closeExisting() {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
    } catch (_) {
      // Ignore close failures so they never block showing a new message.
    }

    try {
      final ctx = _messengerContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
      }
    } catch (_) {
      // Ignore messenger close failures.
    }
  }

  static BuildContext? get _messengerContext =>
      Get.overlayContext ?? Get.context ?? Get.key.currentContext;

  static void _showScaffoldFallback({
    required String title,
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    final ctx = _messengerContext;
    if (ctx == null) return;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          '$title\n$message',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static void _showNow(
    _SnackbarKind kind,
    String title,
    String message, {
    Duration? duration,
  }) {
    _closeExisting();

    final Color backgroundColor;
    final IconData icon;
    final Duration defaultDuration;

    switch (kind) {
      case _SnackbarKind.success:
        backgroundColor = successColor;
        icon = Icons.check_circle;
        defaultDuration = const Duration(seconds: 3);
        break;
      case _SnackbarKind.error:
        backgroundColor = errorColor;
        icon = Icons.error;
        defaultDuration = const Duration(seconds: 4);
        break;
      case _SnackbarKind.warning:
        backgroundColor = warningColor;
        icon = Icons.warning;
        defaultDuration = const Duration(seconds: 3);
        break;
      case _SnackbarKind.info:
        backgroundColor = infoColor;
        icon = Icons.info;
        defaultDuration = const Duration(seconds: 3);
        break;
      case _SnackbarKind.primary:
        backgroundColor = primaryColor;
        icon = Icons.notifications;
        defaultDuration = const Duration(seconds: 3);
        break;
    }

    final effectiveDuration = duration ?? defaultDuration;

    try {
      if (_messengerContext == null) {
        _showScaffoldFallback(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          duration: effectiveDuration,
        );
        return;
      }

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: effectiveDuration,
        icon: Icon(icon, color: Colors.white),
      );
    } catch (_) {
      _showScaffoldFallback(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        duration: effectiveDuration,
      );
    }
  }

  static void _show(
    _SnackbarKind kind,
    String title,
    String message, {
    Duration? duration,
  }) {
    _showAfterFrame(
      () => _showNow(kind, title, message, duration: duration),
    );
  }

  static void _showAfterFrame(
    void Function() show, {
    Duration delay = Duration.zero,
  }) {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      scheduler.addPostFrameCallback((_) {
        if (delay == Duration.zero) {
          show();
          return;
        }
        Future.delayed(delay, show);
      });
      scheduler.scheduleFrame();
      return;
    }

    scheduler.addPostFrameCallback((_) {
      if (delay == Duration.zero) {
        show();
        return;
      }
      Future.delayed(delay, show);
    });
  }

  static void showSuccess(String title, String message, {Duration? duration}) {
    _show(_SnackbarKind.success, title, message, duration: duration);
  }

  static void showError(String title, String message, {Duration? duration}) {
    _show(_SnackbarKind.error, title, message, duration: duration);
  }

  static void showWarning(String title, String message, {Duration? duration}) {
    _show(_SnackbarKind.warning, title, message, duration: duration);
  }

  static void showInfo(String title, String message, {Duration? duration}) {
    _show(_SnackbarKind.info, title, message, duration: duration);
  }

  static void showPrimary(String title, String message, {Duration? duration}) {
    _show(_SnackbarKind.primary, title, message, duration: duration);
  }

  /// Show after the next frame so the snackbar survives route changes.
  static void showSuccessAfterNav(
    String title,
    String message, {
    Duration? duration,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _showAfterFrame(
      () => _showNow(_SnackbarKind.success, title, message, duration: duration),
      delay: delay,
    );
  }

  static void showErrorAfterNav(
    String title,
    String message, {
    Duration? duration,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _showAfterFrame(
      () => _showNow(_SnackbarKind.error, title, message, duration: duration),
      delay: delay,
    );
  }

  static void showWarningAfterNav(
    String title,
    String message, {
    Duration? duration,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _showAfterFrame(
      () => _showNow(_SnackbarKind.warning, title, message, duration: duration),
      delay: delay,
    );
  }

  static void showInfoAfterNav(
    String title,
    String message, {
    Duration? duration,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _showAfterFrame(
      () => _showNow(_SnackbarKind.info, title, message, duration: duration),
      delay: delay,
    );
  }
}
