import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// BuildContext extensions for common operations
extension BuildContextX on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if dark mode is enabled
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get primary color from theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Show a snackbar
  void showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.danger : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius8),
      ),
      margin: const EdgeInsets.all(AppSizes.spacing16),
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Show loading overlay
  void showLoading() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Hide loading overlay
  void hideLoading() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }

  /// Navigate with replacement
  Future<void> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
  }

  /// Navigate to a new screen
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  /// Pop the current screen
  void pop<T>([T? result]) {
    Navigator.pop<T>(this, result);
  }

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
}
