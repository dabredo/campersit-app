import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_inline_spinner.dart';

void main() {
  testWidgets('AppInlineSpinner renders CircularProgressIndicator with given size and color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppInlineSpinner(color: AppColors.primaryAccent, size: 14),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sizedBox.width, equals(14));
    expect(sizedBox.height, equals(14));

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.color, equals(AppColors.primaryAccent));
  });
}

