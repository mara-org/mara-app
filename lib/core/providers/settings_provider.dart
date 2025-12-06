import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_cache.dart';

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
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await LocalCache.init();
    
    // Load theme mode
    final themeModeIndex = LocalCache.getInt('themeMode');
    if (themeModeIndex != null) {
      final themeMode = AppThemeMode.values[themeModeIndex];
      state = state.copyWith(themeMode: themeMode);
    }
    
    // Load health reminders
    final healthReminders = LocalCache.getBool('healthReminders');
    if (healthReminders != null) {
      state = state.copyWith(healthReminders: healthReminders);
    }
    
    // Load email notifications
    final emailNotifications = LocalCache.getBool('emailNotifications');
    if (emailNotifications != null) {
      state = state.copyWith(emailNotifications: emailNotifications);
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await LocalCache.saveInt('themeMode', mode.index);
  }

  Future<void> setHealthReminders(bool value) async {
    state = state.copyWith(healthReminders: value);
    await LocalCache.saveBool('healthReminders', value);
  }

  Future<void> setEmailNotifications(bool value) async {
    state = state.copyWith(emailNotifications: value);
    await LocalCache.saveBool('emailNotifications', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
