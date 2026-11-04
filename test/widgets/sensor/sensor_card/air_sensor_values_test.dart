import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/sensor/sensor_card/air_sensor_values.dart';

void main() {
  group('AirSensorValues', () {
    testWidgets('renders nothing when both temperature and humidity are null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AirSensorValues())),
      );

      expect(find.byType(ScalarMetric), findsNothing);
    });

    testWidgets('renders temperature and humidity metrics when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AirSensorValues(temperature: 22, humidity: 48),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('ºC'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });
  });
}

