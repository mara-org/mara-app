class PermissionsState {
  final bool camera;
  final bool microphone;
  final bool notifications;
  final bool healthData;

  PermissionsState({
    this.camera = false,
    this.microphone = false,
    this.notifications = false,
    this.healthData = false,
  });

  PermissionsState copyWith({
    bool? camera,
    bool? microphone,
    bool? notifications,
    bool? healthData,
  }) {
    return PermissionsState(
      camera: camera ?? this.camera,
      microphone: microphone ?? this.microphone,
      notifications: notifications ?? this.notifications,
      healthData: healthData ?? this.healthData,
    );
  }
}

