import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1Static,
        displayMedium: AppTextStyles.heading2Static,
        displaySmall: AppTextStyles.heading2Static,
        headlineLarge: AppTextStyles.heading1Static,
        headlineMedium: AppTextStyles.heading2Static,
        headlineSmall: AppTextStyles.heading2Static,
        titleLarge: AppTextStyles.heading2Static,
        titleMedium: AppTextStyles.bodyStatic,
        titleSmall: AppTextStyles.bodyStatic,
        bodyLarge: AppTextStyles.bodyStatic,
        bodyMedium: AppTextStyles.bodyStatic,
        bodySmall: AppTextStyles.captionStatic,
        labelLarge: AppTextStyles.bodyStatic,
        labelMedium: AppTextStyles.captionStatic,
        labelSmall: AppTextStyles.captionStatic,
      ).apply(fontFamily: 'Roboto'),
      // Platform-aware button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.secondary,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          ),
          elevation: isIOS ? 0 : 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          ),
        ),
      ),
      // Card theme for consistent card styling
      cardTheme: CardThemeData(
        elevation: isIOS ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    return baseTheme;
  }
}
