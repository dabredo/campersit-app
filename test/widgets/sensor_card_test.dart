import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/widgets/sensor_card.dart';

void main() {
  group('SensorCard Widget Tests', () {
    testWidgets('renders sensor tag, state badge, and battery', (tester) async {
      final seenTime = DateTime(2026, 10, 18, 14, 30);
      final sensor = Sensor(
        id: 'sensor-air-1',
        type: SensorType.air,
        state: SensorState.enabled,
        tag: 'Kitchen Air Sensor',
        battery: 88,
        seenAt: seenTime.millisecondsSinceEpoch,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorCard(sensor: sensor),
          ),
        ),
      );

      expect(find.text('Kitchen Air Sensor'), findsOneWidget);
      expect(find.text('AIR'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('18/10/2026 14:30'), findsOneWidget);
    });

    testWidgets('renders triggered state badge', (tester) async {
      const sensor = Sensor(
        id: 'motion-1',
        type: SensorType.motion,
        state: SensorState.triggered,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(sensor: sensor),
          ),
        ),
      );

      expect(find.text('motion-1'), findsOneWidget);
      expect(find.text('Triggered'), findsOneWidget);
    });

    testWidgets('renders sensor id as fallback when tag is absent', (tester) async {
      const sensor = Sensor(
        id: 'motion-2',
        type: SensorType.motion,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(sensor: sensor),
          ),
        ),
      );

      expect(find.text('motion-2'), findsOneWidget);
    });
  });
}
