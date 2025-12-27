import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension BuildContextExt on BuildContext {
  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  /// Push ke halaman baru
  Future<T?> push<T>(Widget page) {
    return Navigator.push<T>(this, MaterialPageRoute(builder: (_) => page));
  }

  /// Push dan replace halaman saat ini
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      this,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push dan hapus semua halaman sebelumnya
  Future<T?> pushAndRemoveUntil<T>(
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  /// Pop halaman saat ini
  void pop<T>([T? result]) => Navigator.pop<T>(this, result);

  // ═══════════════════════════════════════════════════════════════
  // DEVICE SIZE
  // ═══════════════════════════════════════════════════════════════

  double get deviceHeight => MediaQuery.of(this).size.height;
  double get deviceWidth => MediaQuery.of(this).size.width;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  // ═══════════════════════════════════════════════════════════════
  // SNACKBAR
  // ═══════════════════════════════════════════════════════════════

  void showSnackBar(String message, {Color? backgroundColor, IconData? icon}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showSuccess(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  void showError(String message) {
    showSnackBar(message, backgroundColor: AppColors.error, icon: Icons.error);
  }

  void showWarning(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
    );
  }

  void showInfo(String message) {
    showSnackBar(message, backgroundColor: AppColors.primary, icon: Icons.info);
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOG
  // ═══════════════════════════════════════════════════════════════

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> showLoadingDialog({String message = 'Loading...'}) {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(message),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
