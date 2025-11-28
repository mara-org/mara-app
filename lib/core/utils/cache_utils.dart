import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheUtils {
  CacheUtils._();

  /// Clears shared preferences and known on-device cache directories.
  static Future<void> clearLocalCaches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final tempDir = await getTemporaryDirectory();
    final appSupportDir = await getApplicationSupportDirectory();
    final documentsDir = await getApplicationDocumentsDirectory();

    await Future.wait([
      _deleteDirectoryIfExists(tempDir),
      _deleteDirectoryIfExists(appSupportDir),
      _deleteDirectoryIfExists(documentsDir),
    ]);
  }

  static Future<void> _deleteDirectoryIfExists(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

