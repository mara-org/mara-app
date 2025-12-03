import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppTextStyles {
  AppTextStyles._();

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  // Responsive font sizes that work on both platforms
  static TextStyle heading1(BuildContext context) {
    final baseSize = isIOS ? 34.0 : 32.0;
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: baseSize,
      fontWeight: FontWeight.bold,
      letterSpacing: isIOS ? -0.5 : 0,
      height: 1.2,
    );
  }

  static TextStyle heading2(BuildContext context) {
    final baseSize = isIOS ? 28.0 : 24.0;
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: baseSize,
      fontWeight: FontWeight.bold,
      letterSpacing: isIOS ? -0.3 : 0,
      height: 1.3,
    );
  }

  static TextStyle body(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  static TextStyle caption(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.4,
    );
  }

  // Static versions for theme (without context)
  static const TextStyle heading1Static = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2Static = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle bodyStatic = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle captionStatic = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}
