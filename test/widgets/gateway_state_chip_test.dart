import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/gateway_state_chip.dart';

void main() {
  group('GatewayStateChip Widget Tests', () {
    testWidgets('renders Connected label for connected state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GatewayStateChip(state: 'c'),
          ),
        ),
      );

      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('renders Localizing... label for localizing state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GatewayStateChip(state: 'l'),
          ),
        ),
      );

      expect(find.text('Localizing...'), findsOneWidget);
    });

    testWidgets('renders Inactive label for inactive state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GatewayStateChip(state: 'i'),
          ),
        ),
      );

      expect(find.text('Inactive'), findsOneWidget);
    });
  });
}
