import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_capabilities.dart';
import '../services/session_service.dart';
import '../network/api_client.dart';
import '../di/dependency_injection.dart';

/// Provider for [SessionService].
final sessionServiceProvider = Provider<SessionService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SessionService(apiClient);
});

/// Provider for [AppCapabilities] state.
///
/// This is the single source of truth for user capabilities.
/// Automatically loads from backend session when user signs in.
final appCapabilitiesProvider =
    StateNotifierProvider<AppCapabilitiesNotifier, AppCapabilities?>((ref) {
  final sessionService = ref.read(sessionServiceProvider);
  return AppCapabilitiesNotifier(sessionService);
});

/// Notifier for managing app capabilities state.
class AppCapabilitiesNotifier extends StateNotifier<AppCapabilities?> {
  final SessionService _sessionService;

  AppCapabilitiesNotifier(this._sessionService) : super(null);

  /// Create backend session and load capabilities.
  ///
  /// Call this after Firebase sign-in.
  Future<void> createSession() async {
    try {
      final capabilities = await _sessionService.createSession();
      state = capabilities;
    } catch (e) {
      // Error handling is done in SessionService
      // State remains null if session creation fails
      rethrow;
    }
  }

  /// Refresh capabilities from backend.
  Future<void> refresh() async {
    try {
      final capabilities = await _sessionService.refreshSession();
      state = capabilities;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear capabilities (on sign out).
  void clear() {
    _sessionService.clearCapabilities();
    state = null;
  }

  /// Update capabilities locally (e.g., after chat message reduces quota).
  void updateCapabilities(AppCapabilities capabilities) {
    state = capabilities;
  }
}
