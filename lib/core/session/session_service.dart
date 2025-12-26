import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../network/simple_api_client.dart';
import '../network/api_exceptions.dart';
import '../storage/secure_store.dart';
import '../config/app_config.dart';
import '../config/api_config.dart';
import 'app_session.dart';

/// Service for creating backend session after Firebase sign-in.
class SessionService {
  final SimpleApiClient _apiClient = SimpleApiClient();
  final SecureStore _secureStore = SecureStore();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get unique device identifier
  Future<String> _getDeviceId() async {
    try {
      if (Platform.isIOS) {
        final deviceInfo = await _deviceInfo.iosInfo;
        // identifierForVendor: unique per app per device
        // Changes if user deletes and reinstalls app
        return deviceInfo.identifierForVendor ?? 'unknown-ios';
      } else if (Platform.isAndroid) {
        final deviceInfo = await _deviceInfo.androidInfo;
        // Android ID: unique per device (persists across app reinstalls)
        return deviceInfo.id;
      }
    } catch (e) {
      debugPrint('⚠️ SessionService: Failed to get device ID: $e');
    }
    return 'unknown';
  }

  /// Get device name for display
  Future<String> _getDeviceName() async {
    try {
      if (Platform.isIOS) {
        final deviceInfo = await _deviceInfo.iosInfo;
        return '${deviceInfo.name} (${deviceInfo.model})';
      } else if (Platform.isAndroid) {
        final deviceInfo = await _deviceInfo.androidInfo;
        return '${deviceInfo.model} (${deviceInfo.brand})';
      }
    } catch (e) {
      debugPrint('⚠️ SessionService: Failed to get device name: $e');
    }
    return 'Unknown Device';
  }

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
      debugPrint('❌ SessionService: No Firebase user signed in');
      throw Exception('No Firebase user signed in');
    }

    // CRITICAL: Verify email is verified before creating backend session
    // Backend is the source of truth - email MUST be verified via link
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      debugPrint('❌ SessionService: Email not verified - cannot create backend session');
      throw Exception('Email not verified. Please verify your email address before accessing the app.');
    }

    // Get fresh Firebase ID token
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      debugPrint('❌ SessionService: Failed to get Firebase token');
      throw Exception('Failed to get Firebase token');
    }

    final baseUrl = AppConfig.baseUrl;
    // Use versioned endpoint: /api/v1/auth/session
    final endpoint = ApiConfig.sessionEndpoint;
    final fullUrl = '$baseUrl$endpoint';
    
    // Get device identifier and name
    final deviceId = await _getDeviceId();
    final deviceName = await _getDeviceName();
    
    debugPrint('🚀 SessionService: Creating backend session');
    debugPrint('📍 Base URL: $baseUrl');
    debugPrint('📍 Endpoint: $endpoint');
    debugPrint('📍 Full URL: $fullUrl');
    debugPrint('🔑 Has Firebase token: ${idToken.isNotEmpty}');
    debugPrint('🔑 Token length: ${idToken.length}');
    debugPrint('📱 Device ID: $deviceId');
    debugPrint('📱 Device Name: $deviceName');

    // Call backend session endpoint
    // Backend expects: Firebase token in Authorization header, device_id in body
    try {
      // Build request body exactly as backend expects
      final requestBody = <String, dynamic>{
        'device_id': deviceId,  // Required
        if (deviceName.isNotEmpty) 'device_name': deviceName,  // Optional
      };
      
      debugPrint('📤 SessionService: Request body: $requestBody');
      debugPrint('📤 SessionService: device_id type: ${deviceId.runtimeType}, value: $deviceId');
      debugPrint('📤 SessionService: device_name type: ${deviceName.runtimeType}, value: $deviceName');
      
      final response = await _apiClient.post(
        endpoint,
        requestBody,
        // Authorization header is automatically added by SimpleApiClient interceptor
      );
      
      // Check if response contains device limit error
      if (response.containsKey('error')) {
        final errorData = response['error'] as Map<String, dynamic>?;
        final errorReason = errorData?['reason'] as String?;
        
        if (errorReason == 'DEVICE_LIMIT_EXCEEDED') {
          throw DeviceLimitException(
            message: errorData?['message'] as String? ?? 
                     'Device limit exceeded for your plan',
            currentDevices: errorData?['current_devices'] as int? ?? 0,
            maxDevices: errorData?['max_devices'] as int? ?? 1,
            plan: errorData?['plan'] as String? ?? 'free',
            responseData: response,
          );
        }
        
        debugPrint('❌ SessionService: Backend returned error: ${response['error']}');
        throw Exception(errorData?['message'] ?? 'Backend session failed');
      }
      
      debugPrint('✅ SessionService: Backend session created successfully');
      debugPrint('📦 Response keys: ${response.keys.toList()}');

      // Store session in memory
      AppSession.instance.setSession(response);

      // Store backend session token securely (if provided)
      final backendToken = response['token'] as String? ?? 
                          response['session_token'] as String?;
      if (backendToken != null && backendToken.isNotEmpty) {
        await _secureStore.write(key: 'backend_session_token', value: backendToken);
      }

      return response;
    } catch (e, stackTrace) {
      // Re-throw DeviceLimitException as-is
      if (e is DeviceLimitException) {
        rethrow;
      }
      
      debugPrint('❌ SessionService: Error creating backend session');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Error message: ${e.toString()}');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // If error message contains backend details, log them
      final errorString = e.toString();
      if (errorString.contains('correlation_id') || errorString.contains('Backend')) {
        debugPrint('❌ SessionService: Backend error details found in exception');
      }
      
      // Endpoint should be versioned, no fallback needed
      rethrow;
    }
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
      debugPrint('❌ SessionService: No Firebase user signed in');
      throw Exception('No Firebase user signed in');
    }

    final baseUrl = AppConfig.baseUrl;
    // Use versioned endpoint: /api/v1/auth/me
    final endpoint = ApiConfig.getCurrentUserEndpoint;
    final fullUrl = '$baseUrl$endpoint';
    
    debugPrint('🚀 SessionService: Fetching user info');
    debugPrint('📍 Base URL: $baseUrl');
    debugPrint('📍 Endpoint: $endpoint');
    debugPrint('📍 Full URL: $fullUrl');

    // Call backend GET /api/v1/auth/me endpoint
    // SimpleApiClient interceptor automatically attaches Firebase ID token
    // as Authorization: Bearer <idToken>
    final response = await _apiClient.get(endpoint);
    
    debugPrint('✅ SessionService: User info fetched successfully');
    debugPrint('📦 Response keys: ${response.keys.toList()}');

    // Check for error in response
    if (response.containsKey('error')) {
      debugPrint('❌ SessionService: Backend returned error: ${response['error']}');
      throw Exception(response['error']['message'] ?? 'Failed to fetch user info');
    }

    // Update session with user info and entitlements
    // Backend sends: { "plan": "...", "limits": {...}, "entitlements": {...} }
    AppSession.instance.setSession(response);

    return response;
  }
}

