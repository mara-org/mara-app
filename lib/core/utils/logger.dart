import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Structured logging service for Mara app
///
/// Provides structured logging with context (screen, feature, log level).
/// Logs include metadata but never sensitive health data.
///
/// Usage:
/// ```dart
/// Logger.info('User action', screen: 'home_screen', feature: 'navigation');
/// Logger.error('Failed to load data', screen: 'chat_screen', feature: 'api_call');
/// ```
class Logger {
  static String? _appVersion;
  static String? _buildNumber;
  static String? _sessionId;
  static String? _userId;

  /// Initialize logger with app metadata
  ///
  /// Should be called once at app startup
  static Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to get package info: $e', name: 'Logger');
      }
    }
  }

  /// Set session ID for correlation
  ///
  /// Call this when a new session starts
  static void setSessionId(String sessionId) {
    _sessionId = sessionId;
  }

  /// Set user ID for correlation (never log sensitive data)
  ///
  /// Only set non-sensitive user identifiers (e.g., user ID hash, not email)
  static void setUserId(String? userId) {
    _userId = userId;
  }

  /// Log an info message
  static void info(
    String message, {
    String? screen,
    String? feature,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.info, message, screen: screen, feature: feature, extra: extra);
  }

  /// Log a warning message
  static void warning(
    String message, {
    String? screen,
    String? feature,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.warning, message,
        screen: screen, feature: feature, extra: extra);
  }

  /// Log an error message
  static void error(
    String message, {
    String? screen,
    String? feature,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(LogLevel.error, message,
        screen: screen,
        feature: feature,
        error: error,
        stackTrace: stackTrace,
        extra: extra);
  }

  /// Log a debug message (only in debug mode)
  static void debug(
    String message, {
    String? screen,
    String? feature,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      _log(LogLevel.debug, message,
          screen: screen, feature: feature, extra: extra);
    }
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? screen,
    String? feature,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    // Build structured log entry
    final logEntry = <String, dynamic>{
      'level': level.name.toUpperCase(),
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      if (_appVersion != null) 'app_version': _appVersion,
      if (_buildNumber != null) 'build_number': _buildNumber,
      if (_sessionId != null) 'session_id': _sessionId,
      if (_userId != null) 'user_id': _userId,
      if (screen != null) 'screen': screen,
      if (feature != null) 'feature': feature,
      if (error != null) 'error': error.toString(),
      if (extra != null && extra.isNotEmpty) ...extra,
    };

    // Format log message for console output
    final logMessage = _formatLogMessage(logEntry, error, stackTrace);

    // Log to console using dart:developer
    developer.log(
      logMessage,
      name: 'MaraLogger',
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );

    // In release mode, could send to log aggregation service
    // For now, structured logs are available via developer.log
  }

  /// Format log message for console output
  static String _formatLogMessage(
    Map<String, dynamic> logEntry,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('┌─ ${logEntry['level']} ──────────────────────────────');
    buffer.writeln('│ Message: ${logEntry['message']}');
    if (logEntry['screen'] != null) {
      buffer.writeln('│ Screen: ${logEntry['screen']}');
    }
    if (logEntry['feature'] != null) {
      buffer.writeln('│ Feature: ${logEntry['feature']}');
    }
    if (logEntry['session_id'] != null) {
      buffer.writeln('│ Session: ${logEntry['session_id']}');
    }
    if (logEntry['app_version'] != null) {
      buffer.writeln('│ Version: ${logEntry['app_version']} (${logEntry['build_number']})');
    }
    if (error != null) {
      buffer.writeln('│ Error: $error');
    }
    if (logEntry.length > 5) {
      // Has extra fields
      buffer.writeln('│ Extra: ${logEntry.entries.where((e) => !['level', 'message', 'screen', 'feature', 'session_id', 'app_version', 'build_number', 'timestamp', 'error'].contains(e.key)).map((e) => '${e.key}=${e.value}').join(', ')}');
    }
    buffer.write('└─────────────────────────────────────────────');
    return buffer.toString();
  }
}

/// Log levels
enum LogLevel {
  debug(0),
  info(800),
  warning(900),
  error(1000);

  final int value;
  const LogLevel(this.value);
}

