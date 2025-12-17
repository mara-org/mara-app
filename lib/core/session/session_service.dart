import 'package:firebase_auth/firebase_auth.dart';
import '../network/simple_api_client.dart';
import '../storage/secure_store.dart';
import '../config/app_config.dart';
import 'app_session.dart';

/// Service for creating backend session after Firebase sign-in.
class SessionService {
  final SimpleApiClient _apiClient = SimpleApiClient();
  final SecureStore _secureStore = SecureStore();

  /// Create backend session with Firebase token.
  /// 
  /// Sends Firebase ID token to backend for verification.
  /// Stores backend session token securely if provided.
  /// Returns session data on success.
  /// Throws exception on error.
  Future<Map<String, dynamic>> createBackendSession() async {
    // Get Firebase user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No Firebase user signed in');
    }

    // Get fresh Firebase ID token
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to get Firebase token');
    }

    // Call backend session endpoint
    final response = await _apiClient.post(
      AppConfig.sessionEndpoint,
      {
        'id_token': idToken,
      },
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    // Check for error in response
    if (response.containsKey('error')) {
      throw Exception(response['error']['message'] ?? 'Backend session failed');
    }

    // Store session in memory
    AppSession.instance.setSession(response);

    // Store backend session token securely (if provided)
    final backendToken = response['token'] as String? ?? 
                        response['session_token'] as String?;
    if (backendToken != null && backendToken.isNotEmpty) {
      await _secureStore.write(key: 'backend_session_token', value: backendToken);
    }

    return response;
  }

  /// Get stored backend session token.
  Future<String?> getBackendToken() async {
    return await _secureStore.read(key: 'backend_session_token');
  }

  /// Clear backend session token (on logout).
  Future<void> clearBackendToken() async {
    await _secureStore.delete(key: 'backend_session_token');
  }

  /// Fetch current user info and entitlements from backend.
  /// 
  /// Calls GET /v1/auth/me to get user data, plan, entitlements, and limits.
  /// Updates AppSession with the response.
  /// Throws exception on error.
  /// 
  /// Backend response structure:
  /// {
  ///   "plan": "free" | "paid",
  ///   "limits": {
  ///     "messages_remaining": 10
  ///   },
  ///   "entitlements": {...},
  ///   "user": {...}
  /// }
  /// 
  /// The SimpleApiClient interceptor automatically attaches:
  /// Authorization: Bearer <firebaseIdToken>
  Future<Map<String, dynamic>> fetchUserInfo() async {
    // Get Firebase user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No Firebase user signed in');
    }

    // Call backend GET /v1/auth/me endpoint
    // SimpleApiClient interceptor automatically attaches Firebase ID token
    // as Authorization: Bearer <idToken>
    final response = await _apiClient.get(AppConfig.getCurrentUserEndpoint);

    // Check for error in response
    if (response.containsKey('error')) {
      throw Exception(response['error']['message'] ?? 'Failed to fetch user info');
    }

    // Update session with user info and entitlements
    // Backend sends: { "plan": "...", "limits": {...}, "entitlements": {...} }
    AppSession.instance.setSession(response);

    return response;
  }
}

