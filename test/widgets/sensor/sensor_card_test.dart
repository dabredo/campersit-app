import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/providers/sensor_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/sensor/sensor_card.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  group('SensorCard Widget Tests', () {
    const defaultGatewayId = 'gw-1';
    late MockGatewayRepository mockRepository;

    setUp(() {
      mockRepository = MockGatewayRepository();
    });

    Widget createWidget({
      required Sensor sensor,
      String gatewayId = defaultGatewayId,
    }) {
      return ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SensorCard(sensor: sensor, gatewayId: gatewayId),
          ),
        ),
      );
    }

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

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Kitchen Air Sensor'), findsOneWidget);
      expect(find.text('AIR'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);
      expect(find.text('18/10/2026 14:30'), findsOneWidget);
    });

    testWidgets('renders triggered state badge', (tester) async {
      const sensor = Sensor(
        id: 'motion-1',
        type: SensorType.motion,
        state: SensorState.triggered,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('motion-1'), findsOneWidget);
      expect(find.text('Triggered'), findsOneWidget);
    });

    testWidgets('renders active alarms list for boolean and string alert values', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'motion-alert',
        type: SensorType.motion,
        state: SensorState.enabled,
        alerts: {
          'tamper': true,
          'battery_low': false,
          'battery': 'low',
          'vibration': true,
        },
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Alarms:'), findsOneWidget);
      expect(find.text('- tamper'), findsOneWidget);
      expect(find.text('- vibration'), findsOneWidget);
      expect(find.text('- battery: low'), findsOneWidget);
      expect(find.text('- battery_low'), findsNothing);
    });

    testWidgets('does not render alarms list when alerts are all false', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'motion-clean',
        type: SensorType.motion,
        state: SensorState.enabled,
        alerts: {
          'tamper': false,
        },
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Alarms:'), findsNothing);
    });

    testWidgets('renders sensor id as fallback when tag is absent', (
      tester,
    ) async {
      const sensor = Sensor(id: 'motion-2', type: SensorType.motion);

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('motion-2'), findsOneWidget);
    });

    testWidgets('renders edit and delete buttons', (tester) async {
      const sensor = Sensor(
        id: 'sensor-1',
        type: SensorType.air,
        tag: 'Bedroom Air',
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(
        find.byKey(const ValueKey('edit_sensor_tag_sensor-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('delete_sensor_sensor-1')),
        findsOneWidget,
      );
    });

    testWidgets('opens edit dialog and calls updateSensorTag on save', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'sensor-1',
        type: SensorType.air,
        tag: 'Bedroom Air',
      );

      when(
        () => mockRepository.updateSensorTag(
          gatewayId: defaultGatewayId,
          sensorId: 'sensor-1',
          tag: 'Master Bedroom Air',
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(sensor: sensor));

      await tester.tap(find.byKey(const ValueKey('edit_sensor_tag_sensor-1')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Sensor Tag'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Bedroom Air'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Master Bedroom Air');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateSensorTag(
          gatewayId: defaultGatewayId,
          sensorId: 'sensor-1',
          tag: 'Master Bedroom Air',
        ),
      ).called(1);
      expect(find.text('Edit Sensor Tag'), findsNothing);
    });

    testWidgets('opens delete dialog and calls deleteSensor when confirmed', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'sensor-1',
        type: SensorType.air,
        tag: 'Bedroom Air',
      );

      when(
        () => mockRepository.deleteSensor(
          gatewayId: defaultGatewayId,
          sensorId: 'sensor-1',
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(sensor: sensor));

      await tester.tap(find.byKey(const ValueKey('delete_sensor_sensor-1')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Sensor'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete "Bedroom Air"? This will unpair the sensor from the gateway.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.deleteSensor(
          gatewayId: defaultGatewayId,
          sensorId: 'sensor-1',
        ),
      ).called(1);
      expect(find.text('Delete Sensor'), findsNothing);
    });

    testWidgets(
      'displays loading spinner only when its sensor ID is being deleted',
      (tester) async {
        const sensor1 = Sensor(id: 'sensor-1', type: SensorType.air);
        const sensor2 = Sensor(id: 'sensor-2', type: SensorType.air);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              gatewayRepositoryProvider.overrideWithValue(mockRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: Column(
                  key: Key('test_cards_container'),
                  children: [
                    SensorCard(sensor: sensor1, gatewayId: defaultGatewayId),
                    SensorCard(sensor: sensor2, gatewayId: defaultGatewayId),
                  ],
                ),
              ),
            ),
          ),
        );

        final element = tester.element(find.byKey(const Key('test_cards_container')));
        final container = ProviderScope.containerOf(element);

        // Simulate sensor-1 deletion in progress
        container
            .read(
              deleteSensorControllerProvider((
                gatewayId: defaultGatewayId,
                sensorId: 'sensor-1',
              )).notifier,
            )
            .state = true;
        await tester.pump();

        // Sensor 1 should show loading indicator and no delete button
        expect(
          find.byKey(const ValueKey('delete_sensor_sensor-1')),
          findsNothing,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Sensor 2 should still show delete button and not be loading
        expect(
          find.byKey(const ValueKey('delete_sensor_sensor-2')),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders action buttons for paired actuator (Enable and Start) and triggers request', (
      tester,
    ) async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'cam-1',
          state: SensorState.started,
        ),
      ).thenAnswer((_) async {});

      const sensor = Sensor(
        id: 'cam-1',
        type: SensorType.camera,
        state: SensorState.paired,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pump();

      verify(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'cam-1',
          state: SensorState.started,
        ),
      ).called(1);
    });

    testWidgets('renders only Enable button for paired non-actuator', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'motion-1',
        type: SensorType.motion,
        state: SensorState.paired,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
    });

    testWidgets('renders Enable and Pair buttons for triggered motion sensor', (
      tester,
    ) async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'motion-triggered',
          state: SensorState.enabled,
        ),
      ).thenAnswer((_) async {});

      const sensor = Sensor(
        id: 'motion-triggered',
        type: SensorType.motion,
        state: SensorState.triggered,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Pair'), findsOneWidget);

      await tester.tap(find.text('Enable'));
      await tester.pump();

      verify(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'motion-triggered',
          state: SensorState.enabled,
        ),
      ).called(1);
    });

    testWidgets('renders Pair button for enabled sensor and handles request', (
      tester,
    ) async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'air-enabled',
          state: SensorState.paired,
        ),
      ).thenAnswer((_) async {});

      const sensor = Sensor(
        id: 'air-enabled',
        type: SensorType.air,
        state: SensorState.enabled,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Pair'), findsOneWidget);
      expect(find.text('Enable'), findsNothing);

      await tester.tap(find.text('Pair'));
      await tester.pump();

      verify(
        () => mockRepository.sendRequestState(
          gatewayId: defaultGatewayId,
          sensorId: 'air-enabled',
          state: SensorState.paired,
        ),
      ).called(1);
    });

    testWidgets('renders temperature and humidity for air sensor when values are present', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'air-with-values',
        type: SensorType.air,
        state: SensorState.enabled,
        values: {
          'temperature': 21,
          'humidity': 48,
        },
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('ºC'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('does not render telemetry section when air sensor has no values', (
      tester,
    ) async {
      const sensor = Sensor(
        id: 'air-without-values',
        type: SensorType.air,
        state: SensorState.enabled,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.text('Temperature'), findsNothing);
      expect(find.text('Humidity'), findsNothing);
    });

    testWidgets('renders recordings button for camera sensor', (tester) async {
      const sensor = Sensor(
        id: 'cam-01',
        type: SensorType.camera,
        state: SensorState.enabled,
      );

      await tester.pumpWidget(createWidget(sensor: sensor));

      expect(find.byType(CameraRecordingsButton), findsOneWidget);
      expect(find.text('Recordings'), findsOneWidget);
    });
  });
}


