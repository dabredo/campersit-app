import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/gateway/sensors_sliver.dart';
import 'package:campersit_app/widgets/sensor/sensor_card.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  const gatewayId = 'gw-test-1';
  late MockGatewayRepository mockRepository;

  setUp(() {
    mockRepository = MockGatewayRepository();
  });

  Widget buildTestWidget({
    required List<Sensor> sensors,
    double surfaceWidth = 400,
  }) {
    return ProviderScope(
      overrides: [
        gatewayRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(surfaceWidth, 800)),
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SensorsSliver(gatewayId: gatewayId, sensors: sensors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('SensorsSliver', () {
    testWidgets('renders empty state and inline add sensor card when empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(sensors: []));

      expect(find.text('No Sensors Configured'), findsOneWidget);
      expect(find.byType(AddSensorCard), findsOneWidget);
      expect(find.text('Add Sensor'), findsOneWidget);
    });

    testWidgets('renders sensor cards followed by inline add card', (
      tester,
    ) async {
      const sensors = [
        Sensor(id: 's1', type: SensorType.air, tag: 'Living Room'),
        Sensor(id: 's2', type: SensorType.motion, tag: 'Doorway'),
      ];

      await tester.pumpWidget(buildTestWidget(sensors: sensors));

      expect(find.byType(SensorCard), findsNWidgets(2));
      expect(find.text('Living Room'), findsOneWidget);
      expect(find.text('Doorway'), findsOneWidget);
      expect(find.byType(AddSensorCard), findsOneWidget);
    });

    testWidgets('renders grid layout on wide screens', (tester) async {
      const sensors = [
        Sensor(id: 's1', type: SensorType.air, tag: 'Air 1'),
      ];

      await tester.pumpWidget(
        buildTestWidget(sensors: sensors, surfaceWidth: 800),
      );

      expect(find.byType(SensorCard), findsOneWidget);
      expect(find.byType(AddSensorCard), findsOneWidget);
    });

    testWidgets('opens AddSensorBottomSheet when tapping AddSensorCard', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(sensors: []));

      await tester.tap(find.byType(AddSensorCard));
      await tester.pumpAndSettle();

      expect(find.text('Sensor ID'), findsOneWidget);
    });
  });

  group('SensorsSectionHeader', () {
    testWidgets('renders header with sensor count badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorsSectionHeader(sensorCount: 5),
          ),
        ),
      );

      expect(find.text('Sensors'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.sensors_rounded), findsOneWidget);
    });
  });
}
