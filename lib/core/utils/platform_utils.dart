import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class PlatformUtils {
  PlatformUtils._();

  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMobile => isIOS || isAndroid;

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getSafeAreaHeight(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top + padding.bottom;
  }

  static EdgeInsets getDefaultPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isMobile ? 20.0 : 40.0,
      vertical: 16.0,
    );
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) > 600;
  }

  static String getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'Unknown';
    }
  }
}
