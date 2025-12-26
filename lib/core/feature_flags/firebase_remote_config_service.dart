import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feature_flag_service.dart';

/// Firebase Remote Config implementation for feature flags
///
/// Requires Firebase to be initialized.
/// Frontend-only: reads feature flags from Firebase Remote Config.
///
/// Usage:
/// ```dart
/// final remoteConfig = FirebaseRemoteConfigService();
/// await FeatureFlagService.init(remoteConfig: remoteConfig);
/// ```
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  /// Initialize Firebase Remote Config
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // Check if Firebase is initialized before accessing Remote Config
    if (Firebase.apps.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ Firebase not initialized, skipping Remote Config initialization');
      }
      _initialized = false;
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set defaults (fallback if Remote Config not available)
      await _remoteConfig!.setDefaults({
        'new_chat_ui': false,
        'enhanced_analytics': true,
        'offline_mode': true,
        'experimental_features': false,
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase Remote Config not available: $e');
        debugPrint('Feature flags will use local defaults');
      }
      _initialized = false;
    }
  }

  @override
  Future<void> fetch() async {
    await _ensureInitialized();

    if (_remoteConfig == null) {
      return;
    }

    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch Remote Config: $e');
      }
    }
  }

  @override
  bool getBool(String key) {
    if (_remoteConfig == null) {
      return false;
    }

    try {
      return _remoteConfig!.getBool(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get bool flag: $key, error: $e');
      }
      return false;
    }
  }

  @override
  String getString(String key) {
    if (_remoteConfig == null) {
      return '';
    }

    try {
      return _remoteConfig!.getString(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get string flag: $key, error: $e');
      }
      return '';
    }
  }

  @override
  Map<String, bool> getAllFlags() {
    if (_remoteConfig == null) {
      return {};
    }

    try {
      final allKeys = _remoteConfig!.getAll();
      final flags = <String, bool>{};

      for (final entry in allKeys.entries) {
        try {
          flags[entry.key] = entry.value.asBool();
        } catch (e) {
          // Skip non-bool values
        }
      }

      return flags;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get all flags: $e');
      }
      return {};
    }
  }
}
