import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_state_chip.dart';

void main() {
  group('AppStateChip Widget Tests', () {
    testWidgets('renders label and indicator dot with provided color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppStateChip(
              label: 'Active',
              color: AppColors.primaryAccent,
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Active'));
      expect(textWidget.style?.color, equals(AppColors.primaryAccent));
    });
  });
}
