import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'system_info_service.dart';

final systemInfoServiceProvider = Provider<SystemInfoService>((ref) {
  return SystemInfoService();
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final service = ref.read(systemInfoServiceProvider);
  return service.getAppVersion();
});

final deviceInfoProvider = FutureProvider<String>((ref) async {
  final service = ref.read(systemInfoServiceProvider);
  return service.getDeviceInfo();
});
