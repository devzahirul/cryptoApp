import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Apple-inspired theme configuration
/// Light and dark themes with SF Pro-like typography
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.border,

      // Typography - System font (SF Pro on iOS, Roboto on Android)
      textTheme: _lightTextTheme,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.label,
        onError: Colors.white,
      ),

      // Input decoration
      inputDecorationTheme: _lightInputDecoration,

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing24,
            vertical: AppSizes.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.label,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppSizes.textTitle2,
          fontWeight: FontWeight.w600,
          color: AppColors.label,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.borderDark,

      // Typography - System font (SF Pro on iOS, Roboto on Android)
      textTheme: _darkTextTheme,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.labelDark,
        onError: Colors.white,
      ),

      // Input decoration
      inputDecorationTheme: _darkInputDecoration,

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing24,
            vertical: AppSizes.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.labelDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppSizes.textTitle2,
          fontWeight: FontWeight.w600,
          color: AppColors.labelDark,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondLabelDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Light text theme
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppSizes.textLargeTitle,
      fontWeight: FontWeight.w700,
      color: AppColors.label,
    ),
    displayMedium: TextStyle(
      fontSize: AppSizes.textTitle1,
      fontWeight: FontWeight.w700,
      color: AppColors.label,
    ),
    displaySmall: TextStyle(
      fontSize: AppSizes.textTitle2,
      fontWeight: FontWeight.w600,
      color: AppColors.label,
    ),
    headlineMedium: TextStyle(
      fontSize: AppSizes.textTitle3,
      fontWeight: FontWeight.w600,
      color: AppColors.label,
    ),
    titleLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w600,
      color: AppColors.label,
    ),
    titleMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w500,
      color: AppColors.label,
    ),
    bodyLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w400,
      color: AppColors.label,
    ),
    bodyMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w400,
      color: AppColors.secondLabel,
    ),
    bodySmall: TextStyle(
      fontSize: AppSizes.textFootnote,
      fontWeight: FontWeight.w400,
      color: AppColors.secondLabel,
    ),
    labelLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    labelMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    labelSmall: TextStyle(
      fontSize: AppSizes.textCaption,
      fontWeight: FontWeight.w500,
      color: AppColors.secondLabel,
    ),
  );

  // Dark text theme
  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppSizes.textLargeTitle,
      fontWeight: FontWeight.w700,
      color: AppColors.labelDark,
    ),
    displayMedium: TextStyle(
      fontSize: AppSizes.textTitle1,
      fontWeight: FontWeight.w700,
      color: AppColors.labelDark,
    ),
    displaySmall: TextStyle(
      fontSize: AppSizes.textTitle2,
      fontWeight: FontWeight.w600,
      color: AppColors.labelDark,
    ),
    headlineMedium: TextStyle(
      fontSize: AppSizes.textTitle3,
      fontWeight: FontWeight.w600,
      color: AppColors.labelDark,
    ),
    titleLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w600,
      color: AppColors.labelDark,
    ),
    titleMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w500,
      color: AppColors.labelDark,
    ),
    bodyLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w400,
      color: AppColors.labelDark,
    ),
    bodyMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w400,
      color: AppColors.secondLabelDark,
    ),
    bodySmall: TextStyle(
      fontSize: AppSizes.textFootnote,
      fontWeight: FontWeight.w400,
      color: AppColors.secondLabelDark,
    ),
    labelLarge: TextStyle(
      fontSize: AppSizes.textBody,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    labelMedium: TextStyle(
      fontSize: AppSizes.textSubhead,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    labelSmall: TextStyle(
      fontSize: AppSizes.textCaption,
      fontWeight: FontWeight.w500,
      color: AppColors.secondLabelDark,
    ),
  );

  // Light input decoration
  static const InputDecorationTheme _lightInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacing16,
      vertical: AppSizes.spacing12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.danger, width: 2),
    ),
    hintStyle: TextStyle(
      color: AppColors.secondLabel,
      fontSize: AppSizes.textBody,
    ),
    labelStyle: TextStyle(
      color: AppColors.secondLabel,
      fontSize: AppSizes.textBody,
    ),
    errorStyle: TextStyle(
      color: AppColors.danger,
      fontSize: AppSizes.textFootnote,
    ),
  );

  // Dark input decoration
  static const InputDecorationTheme _darkInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacing16,
      vertical: AppSizes.spacing12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputBorderRadius)),
      borderSide: BorderSide(color: AppColors.danger, width: 2),
    ),
    hintStyle: TextStyle(
      color: AppColors.secondLabelDark,
      fontSize: AppSizes.textBody,
    ),
    labelStyle: TextStyle(
      color: AppColors.secondLabelDark,
      fontSize: AppSizes.textBody,
    ),
    errorStyle: TextStyle(
      color: AppColors.danger,
      fontSize: AppSizes.textFootnote,
    ),
  );
}
