import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../storage/local_cache.dart';
import '../utils/logger.dart';
import '../network/simple_api_client.dart';
import '../config/app_config.dart';
import 'notification_service.dart';
import 'health_data_service.dart';
import 'biometric_auth_service.dart';

/// Service to initialize all app services and capabilities at startup.
///
/// This ensures all Xcode-configured capabilities (HealthKit, Push Notifications,
/// Background Modes, etc.) are properly initialized and ready to use.
class AppInitializationService {
  /// Initialize all app services.
  ///
  /// This should be called once at app startup, before running the app.
  static Future<void> initialize() async {
    Logger.info(
      'AppInitializationService: Starting initialization',
      feature: 'app_init',
      screen: 'app_initialization',
    );

    try {
      // 1. Initialize local cache first (needed by other services)
      await LocalCache.init();
      Logger.info(
        'AppInitializationService: LocalCache initialized',
        feature: 'app_init',
        screen: 'app_initialization',
      );

      // 2. Initialize NotificationService (uses Push Notifications capability)
      try {
        final notificationService = NotificationService();
        final notificationInitialized = await notificationService.initialize();
        if (notificationInitialized) {
          Logger.info(
            'AppInitializationService: NotificationService initialized successfully',
            feature: 'app_init',
            screen: 'app_initialization',
          );
        } else {
          Logger.warning(
            'AppInitializationService: NotificationService initialization returned false',
            feature: 'app_init',
            screen: 'app_initialization',
          );
        }
      } catch (e, stackTrace) {
        Logger.error(
          'AppInitializationService: Error initializing NotificationService',
          error: e,
          stackTrace: stackTrace,
          feature: 'app_init',
          screen: 'app_initialization',
        );
        // Continue initialization even if notifications fail
      }

      // 3. Initialize HealthDataService (uses HealthKit capability)
      // Note: HealthDataService initializes lazily, but we can verify it's ready
      try {
        // Just verify the service can be created - actual initialization is lazy
        HealthDataService(); // Service is created and will initialize when used
        Logger.info(
          'AppInitializationService: HealthDataService ready',
          feature: 'app_init',
          screen: 'app_initialization',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'AppInitializationService: Error creating HealthDataService',
          error: e,
          stackTrace: stackTrace,
          feature: 'app_init',
          screen: 'app_initialization',
        );
        // Continue initialization even if health service fails
      }

      // 4. Initialize BiometricAuthService (uses Face ID/Touch ID)
      try {
        final biometricService = BiometricAuthService();
        final isAvailable = await biometricService.isAvailable();
        Logger.info(
          'AppInitializationService: BiometricAuthService initialized - Available: $isAvailable',
          feature: 'app_init',
          screen: 'app_initialization',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'AppInitializationService: Error initializing BiometricAuthService',
          error: e,
          stackTrace: stackTrace,
          feature: 'app_init',
          screen: 'app_initialization',
        );
        // Continue initialization even if biometrics fail
      }

      // 5. Analytics service removed - will be rebuilt with different tool

      // 6. Test backend connection (non-blocking)
      _testBackendConnection();

      Logger.info(
        'AppInitializationService: Initialization complete',
        feature: 'app_init',
        screen: 'app_initialization',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AppInitializationService: Critical error during initialization',
        error: e,
        stackTrace: stackTrace,
        feature: 'app_init',
        screen: 'app_initialization',
      );
      // Don't rethrow - allow app to start even if initialization has issues
    }
  }

  /// Request notification permissions if needed.
  ///
  /// This should be called after the app has started and user context is available.
  static Future<void> requestNotificationPermissions() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissionsIfNeeded();
      Logger.info(
        'AppInitializationService: Notification permissions requested',
        feature: 'app_init',
        screen: 'app_initialization',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'AppInitializationService: Error requesting notification permissions',
        error: e,
        stackTrace: stackTrace,
        feature: 'app_init',
        screen: 'app_initialization',
      );
    }
  }

  /// Test backend connectivity by trying different base URL candidates.
  ///
  /// This is non-blocking and runs in the background.
  /// It helps verify backend connectivity and will show up in backend logs.
  static void _testBackendConnection() {
    // Run in background without blocking app startup
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await _testBackendConnectivity();
      } catch (e, stackTrace) {
        // Silently handle errors - this is just a connectivity test
        debugPrint('⚠️ Backend connectivity test error: $e');
        Logger.warning(
          'Backend connectivity test failed: $e',
          feature: 'app_init',
          screen: 'app_initialization',
        );
      }
    });
  }

  /// Test backend connectivity by trying different base URL candidates.
  static Future<void> _testBackendConnectivity() async {
    Logger.info(
      'AppInitializationService: Starting backend connectivity test',
      feature: 'app_init',
      screen: 'app_initialization',
    );

    final baseUrl = AppConfig.BASE_URL; // Use constant
    debugPrint('🔍 Testing backend connectivity...');
    debugPrint('🔍 Current BASE_URL: $baseUrl');

    // Create a temporary Dio instance for connectivity testing
    final testDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    
    final candidateUrl = baseUrl; // Single base URL to test
    
    try {
      debugPrint('🔍 Testing BASE_URL: $candidateUrl');
      
      // Test /health endpoint
      try {
          final healthUrl = '$candidateUrl/health';
          debugPrint('🔍 GET $healthUrl');
          final startTime = DateTime.now();
          
          final healthResponse = await testDio.getUri(
            Uri.parse(healthUrl),
            options: Options(
              validateStatus: (status) => true,
            ),
          );
          
          final healthDuration = DateTime.now().difference(startTime);
          final healthBodyStr = healthResponse.data?.toString() ?? 'null';
          final healthBodyPreview = healthBodyStr.length > 500 
              ? '${healthBodyStr.substring(0, 500)}...' 
              : healthBodyStr;
          
          debugPrint('✅ Health check response (${healthDuration.inMilliseconds}ms):');
          debugPrint('   Full URL: $healthUrl');
          debugPrint('   Status: ${healthResponse.statusCode}');
          debugPrint('   Headers: ${healthResponse.headers}');
          debugPrint('   Body: $healthBodyPreview');
          
          Logger.info(
            'Backend connectivity test - Health check',
            feature: 'app_init',
            screen: 'app_initialization',
            extra: {
              'candidate_url': candidateUrl,
              'full_url': healthUrl,
              'status_code': healthResponse.statusCode,
              'response_body': healthBodyPreview,
              'latency_ms': healthDuration.inMilliseconds,
            },
          );
          
          // Test /ready endpoint
          try {
            final readyUrl = '$candidateUrl/ready';
            debugPrint('🔍 GET $readyUrl');
            final readyStartTime = DateTime.now();
            
            final readyResponse = await testDio.getUri(
              Uri.parse(readyUrl),
              options: Options(
                validateStatus: (status) => true,
              ),
            );
            
            final readyDuration = DateTime.now().difference(readyStartTime);
            final readyBodyStr = readyResponse.data?.toString() ?? 'null';
            final readyBodyPreview = readyBodyStr.length > 500 
                ? '${readyBodyStr.substring(0, 500)}...' 
                : readyBodyStr;
            
            debugPrint('✅ Ready check response (${readyDuration.inMilliseconds}ms):');
            debugPrint('   Full URL: $readyUrl');
            debugPrint('   Status: ${readyResponse.statusCode}');
            debugPrint('   Headers: ${readyResponse.headers}');
            debugPrint('   Body: $readyBodyPreview');
            
            Logger.info(
              'Backend connectivity test - Ready check',
              feature: 'app_init',
              screen: 'app_initialization',
              extra: {
                'candidate_url': candidateUrl,
                'full_url': readyUrl,
                'status_code': readyResponse.statusCode,
                'response_body': readyBodyPreview,
                'latency_ms': readyDuration.inMilliseconds,
              },
            );
          } catch (e) {
            debugPrint('❌ Ready check failed: $e');
            Logger.warning(
              'Backend connectivity test - Ready check failed',
              feature: 'app_init',
              screen: 'app_initialization',
              extra: {
                'candidate_url': candidateUrl,
                'error': e.toString(),
              },
            );
          }
          
          if (healthResponse.statusCode == 200) {
            debugPrint('✅ SUCCESS: $candidateUrl is reachable');
            return; // Found working URL
          }
        } catch (e) {
          debugPrint('❌ Health check failed: $e');
        }

        // Try /openapi.json as fallback
        try {
          final openApiUrl = '$candidateUrl/openapi.json';
          debugPrint('🔍 GET $openApiUrl');
          final startTime = DateTime.now();
          
          final response = await testDio.getUri(
            Uri.parse(openApiUrl),
            options: Options(
              validateStatus: (status) => true,
            ),
          );
          
          final duration = DateTime.now().difference(startTime);
          debugPrint('✅ OpenAPI check response (${duration.inMilliseconds}ms):');
          debugPrint('   Status: ${response.statusCode}');
          final bodyStr = response.data?.toString() ?? 'null';
          final bodyPreview = bodyStr.length > 500 
              ? '${bodyStr.substring(0, 500)}...' 
              : bodyStr;
          debugPrint('   Body preview: $bodyPreview');
          
          Logger.info(
            'Backend connectivity test - OpenAPI check',
            feature: 'app_init',
            screen: 'app_initialization',
            extra: {
              'candidate_url': candidateUrl,
              'full_url': openApiUrl,
              'status_code': response.statusCode,
              'response_body': bodyPreview,
              'latency_ms': duration.inMilliseconds,
            },
          );
          
          if (response.statusCode == 200) {
            debugPrint('✅ SUCCESS: $candidateUrl is reachable');
            return; // Found working URL
          }
        } catch (e) {
          debugPrint('❌ OpenAPI check failed: $e');
        }
    } catch (e, stackTrace) {
      debugPrint('❌ Connectivity test failed: $e');
      Logger.warning(
        'Backend connectivity test failed',
        feature: 'app_init',
        screen: 'app_initialization',
        extra: {
          'base_url': candidateUrl,
          'error': e.toString(),
        },
      );
    }
  }
}
