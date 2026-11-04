import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/sensor/sensor_card/sensor_footer.dart';

void main() {
  group('SensorFooter', () {
    testWidgets('renders seenAt and battery indicators when provided', (
      tester,
    ) async {
      final seenAt = DateTime(2026, 10, 18, 9, 15).millisecondsSinceEpoch;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorFooter(seenAt: seenAt, battery: 85),
          ),
        ),
      );

      expect(find.text('18/10/2026 09:15'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.byIcon(Icons.battery_full_rounded), findsOneWidget);
    });

    testWidgets('SensorBatteryIndicator resolves low and medium battery icons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SensorBatteryIndicator(battery: 15),
                SensorBatteryIndicator(battery: 40),
                SensorBatteryIndicator(battery: 1500),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.battery_0_bar_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.battery_3_bar_rounded), findsOneWidget);
    });
  });
}

