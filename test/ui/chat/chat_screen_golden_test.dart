// Golden tests for Chat Screen
// Visual regression tests for chat interface in light and dark mode

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mara_app/features/chat/presentation/mara_chat_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Chat Screen Golden Tests', () {
    testGoldens(
      'Chat screen - light mode',
      (WidgetTester tester) async {
        // TODO: Generate golden files first by running: flutter test --update-goldens
        // Then remove skip: true below
        await tester.pumpWidgetBuilder(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              theme: ThemeData.light(),
              home: const MaraChatScreen(),
            ),
          ),
          surfaceSize: const Size(375, 812), // iPhone 11 Pro size
        );

        await screenMatchesGolden(tester, 'chat_screen_light');
      },
    );

    testGoldens(
      'Chat screen - dark mode',
      (WidgetTester tester) async {
        await tester.pumpWidgetBuilder(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              theme: ThemeData.dark(),
              home: const MaraChatScreen(),
            ),
          ),
          surfaceSize: const Size(375, 812), // iPhone 11 Pro size
        );

        await screenMatchesGolden(tester, 'chat_screen_dark');
      },
    );
  }, tags: ['golden']);
}
