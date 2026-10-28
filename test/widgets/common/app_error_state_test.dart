import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/app_error_state.dart';

void main() {
  testWidgets('AppErrorState renders title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppErrorState(title: 'Failed', message: 'Try again later.'),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Try again later.'), findsOneWidget);
  });
}
