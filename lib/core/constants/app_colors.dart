import 'package:flutter/material.dart';

/// Apple-inspired design system colors
/// Based on iOS SF Pro design language
class AppColors {
  AppColors._();

  // Primary brand colors
  static const primary = Color(0xFF007AFF);      // iOS Blue
  static const primaryDark = Color(0xFF0056CC);  // Darker shade for press states

  // Status colors
  static const success = Color(0xFF34C759);      // iOS Green
  static const danger = Color(0xFFFF3B30);       // iOS Red
  static const warning = Color(0xFFFF9500);      // iOS Orange
  static const info = Color(0xFF5856D6);         // iOS Purple

  // Neutral colors
  static const surface = Color(0xFFF2F2F7);      // iOS Gray 6 (background)
  static const surfaceDark = Color(0xFF1C1C1E);  // Dark mode surface
  static const card = Color(0xFFFFFFFF);         // Card background
  static const cardDark = Color(0xFF2C2C2E);     // Dark mode card

  // Text colors
  static const label = Color(0xFF1C1C1E);        // Primary label (almost black)
  static const labelDark = Color(0xFFFFFFFF);    // Dark mode primary label
  static const secondLabel = Color(0xFF8E8E93);  // Secondary label (gray)
  static const secondLabelDark = Color(0xFF98989D); // Dark mode secondary

  // Brand colors
  static const btcOrange = Color(0xFFF7931A);    // Bitcoin brand color
  static const ethBlue = Color(0xFF627EEA);      // Ethereum brand color

  // Border colors
  static const border = Color(0xFFD1D1D6);       // iOS Gray 4
  static const borderDark = Color(0xFF3A3A3C);   // Dark mode border

  // Background colors
  static const background = Color(0xFFF2F2F7);   // App background
  static const backgroundDark = Color(0xFF000000); // Dark mode background

  // BTC specific
  static const btcGradientStart = Color(0xFFF7931A);
  static const btcGradientEnd = Color(0xFFFFB340);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient btcGradient = LinearGradient(
    colors: [btcGradientStart, btcGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow colors
  static Color shadow = Colors.black.withOpacity(0.1);
  static Color shadowLight = Colors.black.withOpacity(0.06);
}
