import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_seen_at_text.dart';

void main() {
  group('AppSeenAtText Widget Tests', () {
    testWidgets('renders formatted date when seenAt is provided', (tester) async {
      final timestamp = DateTime(2026, 10, 18, 14, 30).millisecondsSinceEpoch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSeenAtText(seenAt: timestamp),
          ),
        ),
      );

      final textFinder = find.text('18/10/2026 14:30');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(11));
      expect(textWidget.style?.fontFamily, equals('monospace'));
      expect(textWidget.style?.color, equals(AppColors.textSecondary));
    });

    testWidgets('renders default fallback text when seenAt is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSeenAtText(seenAt: null),
          ),
        ),
      );

      final textFinder = find.text('Not seen yet');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(11));
      expect(textWidget.style?.fontFamily, equals('monospace'));
      expect(textWidget.style?.color, equals(AppColors.textSecondary));
    });

    testWidgets('renders custom fallback text when specified and seenAt is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSeenAtText(seenAt: null, fallbackText: 'Never seen'),
          ),
        ),
      );

      expect(find.text('Never seen'), findsOneWidget);
    });
  });
}
