import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_device_id_text.dart';

void main() {
  group('AppDeviceIdText Widget Tests', () {
    testWidgets('renders device ID text with correct style and overflow settings', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppDeviceIdText(deviceId: 'GW-001-A'),
          ),
        ),
      );

      final textFinder = find.text('GW-001-A');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(15));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w700));
      expect(textWidget.style?.color, equals(AppColors.textPrimary));
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });
  });
}
