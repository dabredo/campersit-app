import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/screens/actuators_screen.dart';
import 'package:campersit_app/widgets/sensor/sensor_card/motion_actions_button.dart';

void main() {
  testWidgets('MotionActionsButton navigates to ActuatorsScreen on tap', (
    tester,
  ) async {
    const sensor = Sensor(
      id: 'MOT-1',
      type: SensorType.motion,
      state: SensorState.enabled,
    );
    const gateway = Gateway(
      id: 'GW-1',
      state: GatewayStates.connected,
      userId: 'user-1',
      sensors: [sensor],
      alerts: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          singleGatewayProvider('GW-1').overrideWith(
            (ref) => Stream.value(gateway),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MotionActionsButton(gatewayId: 'GW-1', sensor: sensor),
          ),
        ),
      ),
    );

    expect(find.text('Actuators'), findsOneWidget);
    await tester.tap(find.text('Actuators'));
    await tester.pumpAndSettle();

    expect(find.byType(ActuatorsScreen), findsOneWidget);
  });
}
