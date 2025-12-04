import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/utils/crash_reporter.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize structured logging
  await Logger.init();

  // Initialize crash reporting with environment
  CrashReporter.initialize();
  await CrashReporter.init(
    environment: const bool.fromEnvironment('dart.vm.product')
        ? 'production'
        : 'development',
  );

  Logger.info(
    'App starting',
    screen: 'main',
    feature: 'app_init',
  );

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

    return MaterialApp.router(
      key: ValueKey(locale.languageCode), // Force rebuild when locale changes
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
