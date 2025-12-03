import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SystemInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Gets the app version information
  /// Returns format: "version (buildNumber)" or just "version" if buildNumber is not available
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      if (buildNumber.isNotEmpty && buildNumber != '0') {
        return '$version ($buildNumber)';
      }
      return version;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Gets device information based on the platform
  /// iOS: "iPhone17,2 (iOS 26.0.1)"
  /// Android: "Pixel 8 Pro (Android 15, SDK 35)"
  /// Other: "Unknown device"
  Future<String> getDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final deviceModel = iosInfo.utsname.machine;
        final osVersion = iosInfo.systemVersion;
        return '$deviceModel (iOS $osVersion)';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final deviceModel = androidInfo.model;
        final osVersion = androidInfo.version.release;
        final sdkVersion = androidInfo.version.sdkInt;
        return '$deviceModel (Android $osVersion, SDK $sdkVersion)';
      } else {
        return 'Unknown device';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
