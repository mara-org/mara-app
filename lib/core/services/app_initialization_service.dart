import '../storage/local_cache.dart';
import '../utils/logger.dart';
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
}

