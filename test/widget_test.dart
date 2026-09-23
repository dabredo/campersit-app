import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/screens/login_screen.dart';
import 'package:campersit_app/theme/app_theme.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('LoginScreen smoke test renders key access elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Campersit Security Portal'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Shows validation errors when form is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap the login button without entering data
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Shows validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid_email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email format'), findsOneWidget);
    });

    testWidgets('Shows validation error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter short password
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}
