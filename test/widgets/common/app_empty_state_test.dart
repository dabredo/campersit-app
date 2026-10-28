import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/app_empty_state.dart';

void main() {
  testWidgets('AppEmptyState renders icon, title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox_rounded,
            title: 'Nothing here',
            message: 'Items will appear here.',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Items will appear here.'), findsOneWidget);
  });
}
