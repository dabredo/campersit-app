import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/sensor/sensor_card/sensor_action_buttons.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockGatewayRepository;

  setUp(() {
    mockGatewayRepository = MockGatewayRepository();
  });

  testWidgets('SensorActionButtons renders transition buttons and requests state', (
    tester,
  ) async {
    when(
      () => mockGatewayRepository.sendRequestState(
        gatewayId: 'GW-1',
        sensorId: 'S-1',
        state: SensorState.enabled,
      ),
    ).thenAnswer((_) async {});

    const sensor = Sensor(
      id: 'S-1',
      type: SensorType.motion,
      state: SensorState.paired,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockGatewayRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SensorActionButtons(sensor: sensor, gatewayId: 'GW-1'),
          ),
        ),
      ),
    );

    expect(find.text('Enable'), findsOneWidget);
    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();

    verify(
      () => mockGatewayRepository.sendRequestState(
        gatewayId: 'GW-1',
        sensorId: 'S-1',
        state: SensorState.enabled,
      ),
    ).called(1);
  });
}
