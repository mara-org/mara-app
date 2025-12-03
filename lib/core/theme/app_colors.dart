import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFFFFFFFF);

  // Add more colors as needed
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);

  // Gradient colors for splash and onboarding
  static const Color gradientStart = Color(0xFF0EA5C6); // #0EA5C6
  static const Color gradientEnd = Color(0xFF10A9CC); // #10A9CC

  // Language selector card color
  static const Color languageCardBackground = Color(
    0xFFE3F7FA,
  ); // RGB(227, 247, 250)

  // Language button color
  static const Color languageButtonColor = Color(
    0xFF0EA5C6,
  ); // RGB(14, 165, 198)

  // Onboarding gradient colors
  static const Color onboardingGradientStart = Color(
    0xFFE0F7FA,
  ); // RGB(224, 247, 250)
  static const Color onboardingGradientEnd = Color(
    0xFFF9FAFB,
  ); // RGB(249, 250, 251)
  static const Color personalizedGradientStart = Color(
    0xFFBAE6FD,
  ); // RGB(186, 230, 253)
  static const Color personalizedGradientEnd = Color(
    0xFF7DD3FC,
  ); // RGB(125, 211, 252)

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // RGB(15, 23, 42)
  static const Color textSecondary = Color(0xFF64748B); // RGB(100, 116, 139)

  // Background colors
  static const Color backgroundLight = Color(0xFFF9FAFB); // RGB(249, 250, 251)
  static const Color borderColor = Color(0xFFE2E8F0); // RGB(226, 232, 240)

  // Button colors
  static const Color appleButtonColor = Color(0xFF0F172A); // RGB(15, 23, 42)

  // Gender button colors
  static const Color femaleButtonColor = Color(
    0xFFFFDADA,
  ); // RGB(255, 218, 218)

  // Permission screen colors
  static const Color cameraPermissionBackground = Color(
    0xFFB4D9FF,
  ); // RGB(180, 217, 255)
  static const Color permissionEnabled = Color(0xFF10B981); // RGB(16, 185, 129)
  static const Color permissionDisabled = Color(
    0xFFA2BCC1,
  ); // RGB(162, 188, 193)
  static const Color permissionCardBackground = Color(
    0xFFC4F4FF,
  ); // RGB(196, 244, 255)

  // Home screen colors
  static const Color homeHeaderBackground = Color(
    0xFF0EA5C6,
  ); // RGB(14, 165, 198)
  static const Color homeCardBackground = Color(
    0xFFF1F5F9,
  ); // RGB(241, 245, 249)
  static const Color homeVitalSignsBackground = Color(
    0xFF0EA5C6,
  ); // RGB(14, 165, 198)
  static const Color homeTipBackground = Color(
    0xFFF1F5F9,
  ); // RGB(241, 245, 249)
}
