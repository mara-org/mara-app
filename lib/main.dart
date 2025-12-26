import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/utils/crash_reporter.dart';
import 'core/utils/logger.dart';
import 'core/services/app_initialization_service.dart';
import 'core/config/app_config.dart';

void main() {
  // Wrap entire main in error handling zone to catch ALL unhandled exceptions
  runZonedGuarded<void>(
    () async {
      await _initializeApp();
    },
    (final error, final stackTrace) {
      // Catch any unhandled exceptions during initialization
      debugPrint('❌ UNHANDLED EXCEPTION in main():');
      debugPrint('❌ Error: $error');
      debugPrint('❌ Error type: ${error.runtimeType}');
      debugPrint('❌ Stack trace: $stackTrace');

      // Try to report to crash reporter if it's initialized
      try {
        CrashReporter.recordError(
          error,
          stackTrace,
          context: 'Unhandled exception in main()',
        );
      } catch (e) {
        // If crash reporter fails, at least log to console
        debugPrint('❌ Failed to report error to crash reporter: $e');
      }

      // In production, we might want to show an error screen
      // For now, we'll let the app try to continue
    },
  );
}

Future<void> _initializeApp() async {
  // CRITICAL: Must be first - ensures Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Initialize error handlers IMMEDIATELY after bindings
  // This must be done BEFORE any operations that might throw exceptions
  // so that all errors are properly caught and logged
  CrashReporter.initialize();

  // Initialize Firebase - CRITICAL: Must succeed before app can use Firebase
  // Firebase will auto-detect GoogleService-Info.plist on iOS if properly configured
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('🔥 FIREBASE INITIALIZATION');
  debugPrint('═══════════════════════════════════════════════════════');

  bool firebaseInitialized = false;
  try {
    // Check if Firebase is already initialized (might be initialized in AppDelegate.swift)
    if (Firebase.apps.isEmpty) {
      debugPrint('🔧 Initializing Firebase from Dart...');
      debugPrint('🔧 Platform: iOS');
      debugPrint(
          '🔧 Expected GoogleService-Info.plist location: ios/Runner/GoogleService-Info.plist');

      // Initialize Firebase with explicit options from firebase_options.dart
      // This ensures Firebase is properly configured before any Firebase/Auth usage
      // Note: Firebase may already be initialized in AppDelegate.swift for iOS
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Verify initialization succeeded
      if (Firebase.apps.isNotEmpty) {
        firebaseInitialized = true;
        final app = Firebase.app();
        debugPrint('✅ Firebase initialized successfully');
        debugPrint('   App name: ${app.name}');
        debugPrint('   Project ID: ${app.options.projectId ?? "MISSING"}');
        debugPrint(
            '   API Key: ${app.options.apiKey?.substring(0, 10) ?? "MISSING"}...');
        debugPrint('   Total apps: ${Firebase.apps.length}');
        debugPrint('═══════════════════════════════════════════════════════');
      } else {
        throw Exception(
            'Firebase.initializeApp() returned but no apps found. Check GoogleService-Info.plist is in ios/Runner/ and added to Xcode target.');
      }
    } else {
      // Firebase was already initialized in AppDelegate.swift (expected behavior)
      firebaseInitialized = true;
      final app = Firebase.app();
      debugPrint('✅ Firebase already initialized (from AppDelegate.swift)');
      debugPrint('   App name: ${app.name}');
      debugPrint('   Project ID: ${app.options.projectId ?? "MISSING"}');
      debugPrint(
          '   API Key: ${app.options.apiKey?.substring(0, 10) ?? "MISSING"}...');
      debugPrint('   Total apps: ${Firebase.apps.length}');
      debugPrint('═══════════════════════════════════════════════════════');
    }
  } catch (e, stackTrace) {
    // Log detailed error information
    debugPrint('❌ CRITICAL: Firebase initialization FAILED');
    debugPrint('❌ Error: $e');
    debugPrint('❌ Error type: ${e.runtimeType}');
    debugPrint('❌ Stack trace: $stackTrace');
    debugPrint('');
    debugPrint('🔍 Troubleshooting steps:');
    debugPrint(
        '1. Verify GoogleService-Info.plist exists at: ios/Runner/GoogleService-Info.plist');
    debugPrint(
        '2. Check GoogleService-Info.plist is added to Runner target in Xcode:');
    debugPrint('   - Open ios/Runner.xcworkspace in Xcode');
    debugPrint(
        '   - Select Runner target > Build Phases > Copy Bundle Resources');
    debugPrint('   - Ensure GoogleService-Info.plist is listed');
    debugPrint('3. Verify Bundle ID matches: com.iammara.maraApp');
    debugPrint(
        '4. Clean build: flutter clean && cd ios && pod install && cd ..');
    debugPrint(
        '5. If using flavors, generate firebase_options.dart: flutterfire configure');
    debugPrint('═══════════════════════════════════════════════════════');

    // Don't continue - Firebase is required for authentication
    // Re-throw to prevent app from starting with broken Firebase
    rethrow;
  }

  // Double-check Firebase is ready before proceeding
  if (!firebaseInitialized || Firebase.apps.isEmpty) {
    final error =
        'Firebase initialization verification failed - no apps found after initialization';
    debugPrint('❌ $error');
    throw Exception(error);
  }

  // Verify Firebase app is actually usable
  try {
    final app = Firebase.app();
    if (app.options.projectId == null || app.options.projectId!.isEmpty) {
      throw Exception(
          'Firebase app initialized but projectId is missing. Check GoogleService-Info.plist configuration.');
    }
    debugPrint(
        '✅ Firebase verification complete - projectId: ${app.options.projectId}');

    // Test Firebase Auth is accessible (critical for sign-in to work)
    try {
      // Access Firebase Auth to verify it's initialized
      FirebaseAuth.instance; // This will throw if Firebase Auth isn't ready
      debugPrint('✅ Firebase Auth instance accessible');
    } catch (e) {
      throw Exception(
          'Firebase Auth not accessible: $e. This will prevent sign-in from working.');
    }
  } catch (e) {
    debugPrint('❌ Firebase verification failed: $e');
    rethrow;
  }

  // Initialize Logger AFTER Firebase (Logger might use Firebase)
  await Logger.init();

  // Initialize crash reporting with environment
  // Note: CrashReporter.initialize() was already called earlier to set up error handlers
  // Now we just configure it with Firebase Crashlytics support
  await CrashReporter.init(
    environment: const bool.fromEnvironment('dart.vm.product')
        ? 'production'
        : 'development',
    useFirebase:
        true, // Enable Firebase Crashlytics now that Firebase is initialized
  );

  // Log BASE_URL configuration at startup
  final baseUrl = AppConfig.baseUrl;
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('🚀 APP STARTUP - BASE_URL CONFIGURATION');
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('📍 BASE_URL: $baseUrl');
  debugPrint('📍 Environment: ${AppConfig.environmentName}');
  debugPrint('📍 Is Debug Mode: ${AppConfig.isDebug}');
  debugPrint(
      '📍 API_BASE_URL override: ${const String.fromEnvironment('API_BASE_URL', defaultValue: 'NOT SET')}');
  debugPrint('═══════════════════════════════════════════════════════');

  Logger.info(
    'App starting',
    screen: 'main',
    feature: 'app_init',
    extra: {
      'base_url': baseUrl,
      'environment': AppConfig.environmentName,
      'is_debug': AppConfig.isDebug,
    },
  );

  // Initialize all app services and Xcode-configured capabilities
  // This initializes: NotificationService, HealthDataService, BiometricAuthService
  await AppInitializationService.initialize();

  // Listen for Firebase email verification status changes
  // This handles deep links when users click verification links in emails
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null && user.emailVerified) {
      debugPrint('✅ Email verified via deep link');
      // The verification screen will handle navigation automatically
    }
  });

  // Handle Firebase password reset deep links
  // Firebase sends password reset links that open the app with oobCode parameter
  // The deep link URL format: com.iammara.maraApp://reset-password?oobCode=...
  // GoRouter automatically extracts oobCode from query parameters and routes to ResetPasswordScreen
  // This listener is kept for logging purposes - actual routing is handled by GoRouter
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    // Password reset doesn't require a signed-in user
    // Deep link handling is done by GoRouter when app opens via URL scheme
    debugPrint('🔐 Firebase auth state changed');
  });

  // Set system UI overlay style for both platforms
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Run app with crash handling
  CrashReporter.runAppWithCrashHandling(const ProviderScope(child: MaraApp()));
}

class MaraApp extends ConsumerWidget {
  const MaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.themeMode == AppThemeMode.dark;

    return MaterialApp.router(
      key: ValueKey(
          '${locale.languageCode}_${isDarkMode}'), // Force rebuild when locale or theme changes
      title: 'Mara',
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      // Support for both platforms
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scales properly on both platforms
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(
              context,
            ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}
