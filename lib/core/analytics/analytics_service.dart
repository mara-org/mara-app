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

  // ============================================
  // SLO Metrics - Client-side performance tracking
  // ============================================

  /// Record app cold start duration
  ///
  /// Call this when the app finishes initializing and the first screen is displayed.
  /// [durationMs] - Time in milliseconds from app start to first screen
  static Future<void> recordAppColdStart({
    required int durationMs,
  }) async {
    await logEvent(
      'app_cold_start',
      parameters: {
        'duration_ms': durationMs,
        'duration_seconds': (durationMs / 1000).toStringAsFixed(2),
      },
    );
  }

  /// Record time to open chat screen
  ///
  /// Call this when the chat screen becomes fully interactive.
  /// [durationMs] - Time in milliseconds from navigation start to screen ready
  static Future<void> recordChatScreenOpen({
    required int durationMs,
  }) async {
    await logEvent(
      'chat_screen_open',
      parameters: {
        'duration_ms': durationMs,
        'duration_seconds': (durationMs / 1000).toStringAsFixed(2),
      },
    );
  }

  /// Record sign-in flow success
  ///
  /// Call this when sign-in completes successfully
  /// [method] - Sign-in method (e.g., 'email', 'google', 'apple')
  /// [durationMs] - Time in milliseconds for the sign-in flow
  static Future<void> recordSignInSuccess({
    required String method,
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'method': method,
      'success': true,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('sign_in_flow', parameters: parameters);
  }

  /// Record sign-in flow failure
  ///
  /// Call this when sign-in fails
  /// [method] - Sign-in method (e.g., 'email', 'google', 'apple')
  /// [error] - Error description (non-sensitive)
  /// [durationMs] - Time in milliseconds before failure
  static Future<void> recordSignInFailure({
    required String method,
    required String error,
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'method': method,
      'success': false,
      'error': error,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('sign_in_flow', parameters: parameters);
  }

  /// Record chat start flow success
  ///
  /// Call this when a chat session starts successfully
  /// [durationMs] - Time in milliseconds to start chat
  static Future<void> recordChatStartSuccess({
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'success': true,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('chat_start_flow', parameters: parameters);
  }

  /// Record chat start flow failure
  ///
  /// Call this when starting a chat fails
  /// [error] - Error description (non-sensitive)
  /// [durationMs] - Time in milliseconds before failure
  static Future<void> recordChatStartFailure({
    required String error,
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'success': false,
      'error': error,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('chat_start_flow', parameters: parameters);
  }

  /// Record message send success
  ///
  /// Call this when a message is sent successfully
  /// [durationMs] - Time in milliseconds to send message
  static Future<void> recordMessageSendSuccess({
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'success': true,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('message_send', parameters: parameters);
  }

  /// Record message send failure
  ///
  /// Call this when sending a message fails
  /// [error] - Error description (non-sensitive)
  /// [durationMs] - Time in milliseconds before failure
  static Future<void> recordMessageSendFailure({
    required String error,
    int? durationMs,
  }) async {
    final parameters = <String, Object>{
      'success': false,
      'error': error,
    };
    if (durationMs != null) {
      parameters['duration_ms'] = durationMs;
      parameters['duration_seconds'] = (durationMs / 1000).toStringAsFixed(2);
    }
    await logEvent('message_send', parameters: parameters);
  }
}
