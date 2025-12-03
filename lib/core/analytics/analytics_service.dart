import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for Mara app
///
/// Provides abstraction for analytics tracking.
/// Currently supports Firebase Analytics (if configured).
/// Can be extended to support other analytics providers.
///
/// Usage:
/// ```dart
/// AnalyticsService.logScreenView('home_screen');
/// AnalyticsService.logEvent('button_clicked', {'button_name': 'chat'});
/// ```
///
/// Note: Firebase Analytics requires Firebase.initializeApp() to be called first.
/// In debug mode, events are logged to console only.
/// In release mode, events are sent to Firebase Analytics (if configured).
class AnalyticsService {
  static FirebaseAnalytics? _firebaseAnalytics;
  static bool _initialized = false;
  static bool _useFirebase = false;

  /// Initialize analytics service
  ///
  /// [firebaseAnalytics] - Firebase Analytics instance (optional)
  /// If provided, Firebase Analytics will be used for tracking
  static void init({FirebaseAnalytics? firebaseAnalytics}) {
    if (_initialized) return;

    _firebaseAnalytics = firebaseAnalytics;
    _useFirebase = firebaseAnalytics != null;

    _initialized = true;

    if (kDebugMode) {
      debugPrint('AnalyticsService initialized');
      if (_useFirebase) {
        debugPrint('Firebase Analytics enabled');
      } else {
        debugPrint('Analytics running in noop mode (console only)');
      }
    }
  }

  /// Log a screen view
  ///
  /// [screenName] - Name of the screen being viewed
  static Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Screen view - $screenName');
    }

    if (!_useFirebase || _firebaseAnalytics == null) {
      return; // Noop if Firebase not configured
    }

    try {
      await _firebaseAnalytics!.logScreenView(
        screenName: screenName,
      );
    } catch (e) {
      // Silently fail - don't crash the app if analytics fails
      if (kDebugMode) {
        debugPrint('Failed to log screen view: $e');
      }
    }
  }

  /// Log a custom event
  ///
  /// [name] - Event name
  /// [parameters] - Optional event parameters
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Event - $name');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('  Parameters: $parameters');
      }
    }

    if (!_useFirebase || _firebaseAnalytics == null) {
      return; // Noop if Firebase not configured
    }

    try {
      await _firebaseAnalytics!.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail - don't crash the app if analytics fails
      if (kDebugMode) {
        debugPrint('Failed to log event: $e');
      }
    }
  }

  /// Log a user property
  ///
  /// [name] - Property name
  /// [value] - Property value
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: User property - $name = $value');
    }

    if (!_useFirebase || _firebaseAnalytics == null) {
      return; // Noop if Firebase not configured
    }

    try {
      await _firebaseAnalytics!.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      // Silently fail
      if (kDebugMode) {
        debugPrint('Failed to set user property: $e');
      }
    }
  }

  /// Log user login
  static Future<void> logLogin({String? loginMethod}) async {
    await logEvent(
      'login',
      parameters: loginMethod != null ? {'method': loginMethod} : null,
    );
  }

  /// Log user signup
  static Future<void> logSignUp({String? signUpMethod}) async {
    await logEvent(
      'sign_up',
      parameters: signUpMethod != null ? {'method': signUpMethod} : null,
    );
  }
}
