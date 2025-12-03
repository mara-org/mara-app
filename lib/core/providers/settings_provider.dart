import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark }

class SettingsState {
  final AppThemeMode themeMode;
  final bool healthReminders;
  final bool emailNotifications;

  SettingsState({
    this.themeMode = AppThemeMode.light,
    this.healthReminders = true,
    this.emailNotifications = false,
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    bool? healthReminders,
    bool? emailNotifications,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      healthReminders: healthReminders ?? this.healthReminders,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setHealthReminders(bool value) {
    state = state.copyWith(healthReminders: value);
  }

  void setEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
