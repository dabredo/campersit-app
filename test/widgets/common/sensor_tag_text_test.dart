import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/sensor_tag_text.dart';

void main() {
  group('SensorTagText Widget Tests', () {
    testWidgets('renders tag with primary accent color when present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorTagText(tag: 'Living Room'),
          ),
        ),
      );

      final textFinder = find.text('Living Room');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, equals(AppColors.primaryAccent));
      expect(textWidget.style?.fontSize, equals(12));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w600));
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('renders Empty tag with grey secondary color when tag is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorTagText(tag: null),
          ),
        ),
      );

      final textFinder = find.text('Empty tag');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(
        textWidget.style?.color,
        equals(AppColors.textSecondary.withValues(alpha: 0.5)),
      );
      expect(textWidget.style?.fontSize, equals(12));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w600));
    });

    testWidgets('renders Empty tag with grey secondary color when tag is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorTagText(tag: ''),
          ),
        ),
      );

      final textFinder = find.text('Empty tag');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(
        textWidget.style?.color,
        equals(AppColors.textSecondary.withValues(alpha: 0.5)),
      );
      expect(textWidget.style?.fontSize, equals(12));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w600));
    });
  });
}
