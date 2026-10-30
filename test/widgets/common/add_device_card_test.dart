import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/add_device_card.dart';

void main() {
  group('AddDeviceCard Widget Tests', () {
    testWidgets('renders title, icon, and handles tap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddDeviceCard(
              title: 'Pair new Gateway',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Pair new Gateway'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.byType(AddDeviceCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders custom margin when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddDeviceCard(
              title: 'Pair new Sensor',
              margin: const EdgeInsets.all(12),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pair new Sensor'), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
