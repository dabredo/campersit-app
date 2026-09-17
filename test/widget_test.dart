import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/screens/login_screen.dart';
import 'package:campersit_app/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen smoke test renders key access elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );

    expect(find.text('Campersit Security Portal'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
