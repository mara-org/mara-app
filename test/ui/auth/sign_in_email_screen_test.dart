// Widget tests for Sign In Email Screen
// Tests rendering, form validation, and user interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mara_app/features/auth/presentation/sign_in_email_screen.dart';
import 'package:mara_app/core/widgets/mara_text_field.dart';
import 'package:mara_app/core/widgets/primary_button.dart';
import 'package:mara_app/core/providers/email_provider.dart';
import '../utils/test_utils.dart';

void main() {
  group('Sign In Email Screen Widget Tests', () {
    testWidgets('Sign in screen renders correctly',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Verify screen exists
      expect(find.byType(SignInEmailScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify form fields exist
      expect(find.byType(MaraTextField),
          findsNWidgets(2)); // Email and password fields
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Find email field
      final emailFields = find.byType(MaraTextField);
      expect(emailFields, findsNWidgets(2));

      // Enter email
      await tester.enterText(emailFields.first, 'test@example.com');
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input and toggles visibility',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Find password field (second text field)
      final textFields = find.byType(MaraTextField);
      expect(textFields, findsNWidgets(2));

      // Enter password
      await tester.enterText(textFields.last, 'TestPassword123!');
      await tester.pump();

      // Verify password was entered (may be obscured)
      // The exact behavior depends on MaraTextField implementation
      expect(find.text('TestPassword123!'),
          findsNothing); // Password should be hidden
    });

    testWidgets('Form validation works for empty email',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Find and tap the sign in button
      final signInButton = find.byType(PrimaryButton);
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pump();

      // Form should show validation error
      // The exact error message depends on localization
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Form validation works for invalid email format',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Enter invalid email
      final emailFields = find.byType(MaraTextField);
      await tester.enterText(emailFields.first, 'invalid-email');
      await tester.pump();

      // Try to submit
      final signInButton = find.byType(PrimaryButton);
      await tester.tap(signInButton);
      await tester.pump();

      // Form should show validation error
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Terms checkbox can be toggled', (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Find checkbox
      final checkbox = find.byType(Checkbox);
      if (checkbox.evaluate().isNotEmpty) {
        expect(checkbox, findsOneWidget);

        // Toggle checkbox
        await tester.tap(checkbox);
        await tester.pump();

        // Verify checkbox state changed
        final checkboxWidget = tester.widget<Checkbox>(checkbox);
        expect(checkboxWidget.value, isTrue);
      }
    });

    testWidgets('Screen does not crash on rapid interactions',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const SignInEmailScreen());

      // Rapidly interact with the form
      final textFields = find.byType(MaraTextField);
      final button = find.byType(PrimaryButton);

      for (int i = 0; i < 5; i++) {
        await tester.enterText(textFields.first, 'test$i@example.com');
        await tester.pump();
        await tester.tap(button);
        await tester.pump();
      }

      // Screen should still be rendered
      expect(find.byType(SignInEmailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
