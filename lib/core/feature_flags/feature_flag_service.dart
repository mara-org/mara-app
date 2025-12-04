import 'package:flutter/foundation.dart';

/// Feature flag service for enabling/disabling features
///
/// Supports canary deployments and staged rollouts via Remote Config.
/// Frontend-only: uses Firebase Remote Config or local defaults.
///
/// Usage:
/// ```dart
/// if (FeatureFlagService.isEnabled('new_chat_ui')) {
///   // Show new UI
/// } else {
///   // Show old UI
/// }
/// ```
class FeatureFlagService {
  static final Map<String, bool> _flags = {};
  static bool _initialized = false;
  static RemoteConfigService? _remoteConfig;

  /// Initialize feature flags
  ///
  /// [remoteConfig] - Optional Remote Config service for dynamic flags
  /// [defaultFlags] - Default flag values (used if Remote Config not available)
  static Future<void> init({
    RemoteConfigService? remoteConfig,
    Map<String, bool>? defaultFlags,
  }) async {
    if (_initialized) return;

    _remoteConfig = remoteConfig;
    _flags.addAll(defaultFlags ?? _getDefaultFlags());

    // Fetch remote config if available
    if (_remoteConfig != null) {
      try {
        await _remoteConfig!.fetch();
        final remoteFlags = _remoteConfig!.getAllFlags();
        _flags.addAll(remoteFlags);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to fetch remote config: $e');
        }
      }
    }

    _initialized = true;

    if (kDebugMode) {
      debugPrint('FeatureFlagService initialized');
      debugPrint(
          'Active flags: ${_flags.entries.where((e) => e.value).map((e) => e.key).join(", ")}');
    }
  }

  /// Check if a feature flag is enabled
  static bool isEnabled(String flagName) {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint(
            'FeatureFlagService not initialized, using default for: $flagName');
      }
      return _getDefaultFlags()[flagName] ?? false;
    }

    return _flags[flagName] ?? false;
  }

  /// Set a feature flag value (for testing or local override)
  static void setFlag(String flagName, bool value) {
    _flags[flagName] = value;
  }

  /// Get all feature flags
  static Map<String, bool> getAllFlags() {
    return Map.unmodifiable(_flags);
  }

  /// Refresh flags from Remote Config
  static Future<void> refresh() async {
    if (_remoteConfig != null) {
      try {
        await _remoteConfig!.fetch();
        final remoteFlags = _remoteConfig!.getAllFlags();
        _flags.addAll(remoteFlags);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to refresh feature flags: $e');
        }
      }
    }
  }

  /// Default feature flags (can be overridden by Remote Config)
  static Map<String, bool> _getDefaultFlags() {
    return {
      // Example flags - adjust based on your needs
      'new_chat_ui': false,
      'enhanced_analytics': true,
      'offline_mode': true,
      'experimental_features': false,
    };
  }
}

/// Abstract interface for Remote Config service
///
/// Implementations can use Firebase Remote Config or other providers
abstract class RemoteConfigService {
  Future<void> fetch();
  bool getBool(String key);
  String getString(String key);
  Map<String, bool> getAllFlags();
}
