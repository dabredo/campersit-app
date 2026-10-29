import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/widgets/gateway/gateway_card.dart';

void main() {
  group('GatewayCard Widget Tests', () {
    testWidgets('renders gateway ID, state chip, and sensor count correctly', (tester) async {
      const gateway = Gateway(
        id: 'gw-camper-1',
        state: GatewayStates.connected,
        userId: 'user-1',
        sensors: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GatewayCard(gateway: gateway),
          ),
        ),
      );

      expect(find.text('gw-camper-1'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('0 Sensors connected'), findsOneWidget);
      expect(find.text('Alarms:'), findsNothing);
    });

    testWidgets('renders singular sensor connected and active alarms', (tester) async {
      const gateway = Gateway(
        id: 'gw-camper-2',
        state: GatewayStates.initialized,
        userId: 'user-1',
        alerts: {'temp': 'Overheating'},
        sensors: [
          Sensor(
            id: 'sensor-1',
            type: SensorType.air,
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GatewayCard(gateway: gateway),
          ),
        ),
      );

      expect(find.text('gw-camper-2'), findsOneWidget);
      expect(find.text('Initialized'), findsOneWidget);
      expect(find.text('1 Sensor connected'), findsOneWidget);
      expect(find.text('Alarms:'), findsOneWidget);
      expect(find.text('- temp: Overheating'), findsOneWidget);
    });
  });
}
