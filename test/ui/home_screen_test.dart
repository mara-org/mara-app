// Widget tests for Home Screen
// Tests the home screen rendering, button interactions, and navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mara_app/features/home/presentation/home_screen.dart';
import 'package:mara_app/core/widgets/primary_button.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/test_utils.dart';

void main() {
  group('Home Screen Widget Tests', () {
    testWidgets('Home screen renders correctly', (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Chat Screen')),
                ),
              ),
            ],
          ),
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
        ),
      );

      // Verify that the HomeScreen widget exists
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify that the Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Home screen displays main elements',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
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
        ),
      );

      // Verify SafeArea exists
      expect(find.byType(SafeArea), findsOneWidget);

      // Verify SingleChildScrollView exists (home screen is scrollable)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Chat button is present and tappable',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Chat Screen')),
                ),
              ),
            ],
          ),
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
        ),
      );

      // Find chat button (PrimaryButton with "Chat with Mara" text)
      final chatButton = find.byType(PrimaryButton);
      expect(chatButton, findsWidgets);

      // Tap the first primary button (assuming it's the chat button)
      if (chatButton.evaluate().isNotEmpty) {
        await tester.tap(chatButton.first);
        await tester.pumpAndSettle();
      }
    });
  });
}

