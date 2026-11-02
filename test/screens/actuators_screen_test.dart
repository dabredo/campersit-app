import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/screens/actuators_screen.dart';
import 'package:campersit_app/widgets/common/app_device_id_text.dart';
import 'package:campersit_app/widgets/common/app_device_type_badge.dart';
import 'package:campersit_app/widgets/common/section_header.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  group('ActuatorsScreen Tests', () {
    const testGatewayId = 'gw-01';
    const testMotionSensor = Sensor(
      id: 'motion-01',
      type: SensorType.motion,
      state: SensorState.enabled,
      tag: 'Front Door Motion',
      actions: ['cam-01'],
    );

    late MockGatewayRepository mockRepository;

    setUp(() {
      mockRepository = MockGatewayRepository();
    });

    Widget createWidget({required List overrides}) {
      return ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockRepository),
          ...overrides.cast(),
        ],
        child: const MaterialApp(
          home: ActuatorsScreen(
            gatewayId: testGatewayId,
            sensor: testMotionSensor,
          ),
        ),
      );
    }

    testWidgets('renders loading indicator when gateway is loading', (tester) async {
      await tester.pumpWidget(
        createWidget(
          overrides: [
            singleGatewayProvider(testGatewayId).overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
        ),
      );

      expect(find.text('ACTUATORS'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error view when stream emits error', (tester) async {
      await tester.pumpWidget(
        createWidget(
          overrides: [
            singleGatewayProvider(testGatewayId).overrideWith(
              (ref) => Stream.error(Exception('Gateway connection failed')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error loading configuration'), findsOneWidget);
      expect(
        find.text('An unexpected error occurred. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when no actuators are paired to gateway', (tester) async {
      final gateway = Gateway(
        id: testGatewayId,
        state: GatewayStates.connected,
        userId: 'user-1',
        alerts: {},
        sensors: [testMotionSensor],
      );

      await tester.pumpWidget(
        createWidget(
          overrides: [
            singleGatewayProvider(testGatewayId).overrideWith(
              (ref) => Stream.value(gateway),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACTUATORS (0)'), findsOneWidget);
      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('Actuators for Front Door Motion'), findsOneWidget);
      expect(find.text('No Actuators Found'), findsOneWidget);
      expect(
        find.text(
          'Pair an actuator (camera, LED, or buzzer) to this gateway to configure trigger actions.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders actuators with identifiable info, header description and count', (tester) async {
      const cameraActuator = Sensor(
        id: 'cam-01',
        type: SensorType.camera,
        state: SensorState.enabled,
        tag: 'Driveway Camera',
      );
      const buzzerActuator = Sensor(
        id: 'buz-01',
        type: SensorType.buzzer,
        state: SensorState.paired,
      );

      final gateway = Gateway(
        id: testGatewayId,
        state: GatewayStates.connected,
        userId: 'user-1',
        alerts: {},
        sensors: [testMotionSensor, cameraActuator, buzzerActuator],
      );

      await tester.pumpWidget(
        createWidget(
          overrides: [
            singleGatewayProvider(testGatewayId).overrideWith(
              (ref) => Stream.value(gateway),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Title should show actuators count
      expect(find.text('ACTUATORS (2)'), findsOneWidget);

      // Header description for the sensor
      expect(find.text('Actuators for Front Door Motion'), findsOneWidget);
      expect(
        find.text(
          'These actuators will execute automatically when this sensor is triggered.',
        ),
        findsOneWidget,
      );

      // Verify removed sections
      expect(find.text('Automated Trigger Actions'), findsNothing);
      expect(find.textContaining('PAIRED ACTUATORS'), findsNothing);

      // Verify actuator widgets
      expect(find.byType(AppDeviceTypeBadge), findsNWidgets(2));
      expect(find.byType(AppDeviceIdText), findsNWidgets(2));

      // Verify camera identification
      expect(find.text('cam-01'), findsOneWidget);
      expect(find.text('Driveway Camera'), findsOneWidget);
      expect(find.text('CAMERA'), findsOneWidget);

      // Verify buzzer identification (without tag, displays Empty tag)
      expect(find.text('buz-01'), findsOneWidget);
      expect(find.text('Empty tag'), findsOneWidget);
      expect(find.text('BUZZER'), findsOneWidget);

      // Verify state badges are not displayed
      expect(find.text('Enabled'), findsNothing);
      expect(find.text('Paired'), findsNothing);

      // Verify switch states: cam-01 is in actions (true), buz-01 is not (false)
      final camSwitch = tester.widget<Switch>(
        find.byKey(const ValueKey('actuator_switch_cam-01')),
      );
      expect(camSwitch.value, isTrue);

      final buzSwitch = tester.widget<Switch>(
        find.byKey(const ValueKey('actuator_switch_buz-01')),
      );
      expect(buzSwitch.value, isFalse);
    });

    testWidgets('toggling switch calls updateSensorAction on repository', (tester) async {
      when(
        () => mockRepository.updateSensorAction(
          gatewayId: testGatewayId,
          sensorId: 'motion-01',
          actuatorId: 'buz-01',
          enabled: true,
        ),
      ).thenAnswer((_) async {});

      const buzzerActuator = Sensor(
        id: 'buz-01',
        type: SensorType.buzzer,
        state: SensorState.paired,
      );

      final gateway = Gateway(
        id: testGatewayId,
        state: GatewayStates.connected,
        userId: 'user-1',
        alerts: {},
        sensors: [testMotionSensor, buzzerActuator],
      );

      await tester.pumpWidget(
        createWidget(
          overrides: [
            singleGatewayProvider(testGatewayId).overrideWith(
              (ref) => Stream.value(gateway),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('actuator_switch_buz-01')));
      await tester.pump();

      verify(
        () => mockRepository.updateSensorAction(
          gatewayId: testGatewayId,
          sensorId: 'motion-01',
          actuatorId: 'buz-01',
          enabled: true,
        ),
      ).called(1);
    });
  });
}
