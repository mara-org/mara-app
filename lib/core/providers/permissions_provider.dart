import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permissions_state.dart';

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  PermissionsNotifier() : super(PermissionsState());

  void setCamera(bool value) {
    state = state.copyWith(camera: value);
  }

  void setMicrophone(bool value) {
    state = state.copyWith(microphone: value);
  }

  void setNotifications(bool value) {
    state = state.copyWith(notifications: value);
  }

  void setHealthData(bool value) {
    state = state.copyWith(healthData: value);
  }

  void reset() {
    state = PermissionsState();
  }
}

final permissionsProvider = StateNotifierProvider<PermissionsNotifier, PermissionsState>(
  (ref) => PermissionsNotifier(),
);

