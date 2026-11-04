import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/app_loading_state.dart';

void main() {
  testWidgets('AppLoadingState renders centered CircularProgressIndicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLoadingState())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

