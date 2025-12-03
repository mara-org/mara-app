import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cache service for offline-ready data storage
///
/// Provides simple key-value storage using SharedPreferences.
/// This is a basic implementation that can be extended later with:
/// - TTL (time-to-live) for cached data
/// - Encryption for sensitive data
/// - Cache size limits
/// - Cache eviction policies
///
/// Usage:
/// ```dart
/// final cache = LocalCache();
/// await cache.saveString('user_name', 'John');
/// final name = await cache.getString('user_name');
/// ```
class LocalCache {
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  /// Initialize the cache (call once at app startup)
  static Future<void> init() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      if (kDebugMode) {
        debugPrint('LocalCache initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize LocalCache: $e');
      }
    }
  }

  /// Save a string value
  ///
  /// [key] - Cache key
  /// [value] - Value to store
  /// Returns true if successful, false otherwise
  static Future<bool> saveString(String key, String value) async {
    if (!_initialized) {
      await init();
    }

    if (_prefs == null) {
      if (kDebugMode) {
        debugPrint('LocalCache not initialized, cannot save: $key');
      }
      return false;
    }

    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save to cache: $e');
      }
      return false;
    }
  }

  /// Get a string value
  ///
  /// [key] - Cache key
  /// Returns the cached value or null if not found
  static String? getString(String key) {
    if (!_initialized || _prefs == null) {
      return null;
    }

    try {
      return _prefs!.getString(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get from cache: $e');
      }
      return null;
    }
  }

  /// Save an integer value
  static Future<bool> saveInt(String key, int value) async {
    if (!_initialized) {
      await init();
    }

    if (_prefs == null) return false;

    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save int to cache: $e');
      }
      return false;
    }
  }

  /// Get an integer value
  static int? getInt(String key) {
    if (!_initialized || _prefs == null) {
      return null;
    }

    try {
      return _prefs!.getInt(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get int from cache: $e');
      }
      return null;
    }
  }

  /// Save a boolean value
  static Future<bool> saveBool(String key, bool value) async {
    if (!_initialized) {
      await init();
    }

    if (_prefs == null) return false;

    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save bool to cache: $e');
      }
      return false;
    }
  }

  /// Get a boolean value
  static bool? getBool(String key) {
    if (!_initialized || _prefs == null) {
      return null;
    }

    try {
      return _prefs!.getBool(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get bool from cache: $e');
      }
      return null;
    }
  }

  /// Remove a value from cache
  static Future<bool> remove(String key) async {
    if (!_initialized) {
      await init();
    }

    if (_prefs == null) return false;

    try {
      return await _prefs!.remove(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to remove from cache: $e');
      }
      return false;
    }
  }

  /// Clear all cached data
  static Future<bool> clear() async {
    if (!_initialized) {
      await init();
    }

    if (_prefs == null) return false;

    try {
      return await _prefs!.clear();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear cache: $e');
      }
      return false;
    }
  }

  /// Check if a key exists in cache
  static bool containsKey(String key) {
    if (!_initialized || _prefs == null) {
      return false;
    }

    return _prefs!.containsKey(key);
  }
}

