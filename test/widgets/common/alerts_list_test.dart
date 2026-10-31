import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/alerts_list.dart';

void main() {
  group('AlertsList', () {
    testWidgets('renders nothing when alerts are empty or inactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertsList(
              alerts: {'tamper': false, 'motion': null, 'empty': ''},
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders active alerts without prefix by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertsList(
              alerts: {'temp': 'Overheating', 'battery': 'low', 'tamper': true},
            ),
          ),
        ),
      );

      expect(find.text('temp: Overheating'), findsOneWidget);
      expect(find.text('battery: low'), findsOneWidget);
      expect(find.text('tamper'), findsOneWidget);
      expect(find.byIcon(Icons.battery_alert_rounded), findsOneWidget);
      expect(find.byIcon(Icons.crisis_alert_rounded), findsOneWidget);
    });

    testWidgets('renders with prefix when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertsList(
              alerts: {'door': 'open', 'tamper': true},
              prefix: 'Alarm: ',
            ),
          ),
        ),
      );

      expect(find.text('Alarm: door: open'), findsOneWidget);
      expect(find.text('Alarm: tamper'), findsOneWidget);
    });

    testWidgets('uses explicit icon override when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertsList(
              alerts: {'missing': true},
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ),
      );

      expect(find.text('missing'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sensors_off_rounded), findsNothing);
    });
  });
}
