import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/utils/date_time_formatter.dart';
import 'package:campersit_app/widgets/gateway/delete_gateway_action.dart';
import 'package:campersit_app/widgets/gateway/gateway_card.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockRepository;

  setUp(() {
    mockRepository = MockGatewayRepository();
  });

  Future<void> pumpGatewayCard(WidgetTester tester, Gateway gateway) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: GatewayCard(gateway: gateway),
          ),
        ),
      ),
    );
  }

  group('GatewayCard Widget Tests', () {
    testWidgets(
      'renders gateway ID, state chip, action buttons above sensor count',
      (tester) async {
        const gateway = Gateway(
          id: 'gw-camper-1',
          state: GatewayStates.connected,
          userId: 'user-1',
          sensors: [],
        );

        await pumpGatewayCard(tester, gateway);

        expect(find.text('gw-camper-1'), findsOneWidget);
        expect(find.text('Connected'), findsOneWidget);
        expect(find.text('Arm'), findsOneWidget);
        expect(find.text('Disarm'), findsOneWidget);
        expect(find.byType(DeleteGatewayAction), findsOneWidget);
        expect(
          find.byKey(const ValueKey('delete_gateway_gw-camper-1')),
          findsOneWidget,
        );
        expect(find.text('0 Sensors connected'), findsOneWidget);
        expect(find.text('Alarms:'), findsNothing);

        // Verify action buttons appear above the sensors connected box
        final armOffset = tester.getTopLeft(find.text('Arm'));
        final sensorsOffset = tester.getTopLeft(find.text('0 Sensors connected'));
        expect(armOffset.dy, lessThan(sensorsOffset.dy));
      },
    );

    testWidgets('arms gateway when tapping arm button', (tester) async {
      const gateway = Gateway(
        id: 'gw-camper-1',
        state: GatewayStates.connected,
        userId: 'user-1',
        sensors: [],
      );
      when(() => mockRepository.armGateway('gw-camper-1'))
          .thenAnswer((_) async {});

      await pumpGatewayCard(tester, gateway);
      await tester.tap(find.text('Arm'));
      await tester.pump();

      verify(() => mockRepository.armGateway('gw-camper-1')).called(1);
    });

    testWidgets('disarms gateway when tapping disarm button', (tester) async {
      const gateway = Gateway(
        id: 'gw-camper-1',
        state: GatewayStates.connected,
        userId: 'user-1',
        sensors: [],
      );
      when(() => mockRepository.disarmGateway('gw-camper-1'))
          .thenAnswer((_) async {});

      await pumpGatewayCard(tester, gateway);
      await tester.tap(find.text('Disarm'));
      await tester.pump();

      verify(() => mockRepository.disarmGateway('gw-camper-1')).called(1);
    });

    testWidgets(
      'renders singular sensor connected and active alarms matching Stitch',
      (tester) async {
        const gateway = Gateway(
          id: 'gw-camper-2',
          state: GatewayStates.initialized,
          userId: 'user-1',
          alerts: {'temp': 'Overheating', 'ignored': false},
          sensors: [
            Sensor(
              id: 'sensor-1',
              type: SensorType.air,
            ),
          ],
        );

        await pumpGatewayCard(tester, gateway);

        expect(find.text('gw-camper-2'), findsOneWidget);
        expect(find.text('Initialized'), findsOneWidget);
        expect(find.text('1 Sensor connected'), findsOneWidget);
        expect(find.text('Alarms:'), findsNothing);
        expect(find.text('temp: Overheating'), findsOneWidget);
        expect(find.text('ignored'), findsNothing);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'renders boolean alarm with key name matching Stitch design',
      (tester) async {
        const gateway = Gateway(
          id: 'gw-camper-3',
          state: GatewayStates.connected,
          userId: 'user-1',
          alerts: {'missing': true},
          sensors: [],
        );

        await pumpGatewayCard(tester, gateway);

        expect(find.text('gw-camper-3'), findsOneWidget);
        expect(find.text('missing'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'renders GPS location header with request button and calls requestLocation when tapped',
      (tester) async {
        const gateway = Gateway(
          id: 'gw-camper-1',
          state: GatewayStates.connected,
          userId: 'user-1',
        );
        when(() => mockRepository.requestLocation('gw-camper-1'))
            .thenAnswer((_) async {});

        await pumpGatewayCard(tester, gateway);

        expect(find.text('GPS Location'), findsOneWidget);
        expect(find.text('Request Location'), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

        await tester.tap(find.text('Request Location'));
        await tester.pump();

        verify(() => mockRepository.requestLocation('gw-camper-1')).called(1);
      },
    );

    testWidgets(
      'renders localizing banner with Stop button and calls stopLocation when tapped',
      (tester) async {
        const gateway = Gateway(
          id: 'gw-camper-1',
          state: GatewayStates.localizing,
          userId: 'user-1',
        );
        when(() => mockRepository.stopLocation('gw-camper-1'))
            .thenAnswer((_) async {});

        await pumpGatewayCard(tester, gateway);

        expect(find.text('GPS Location'), findsOneWidget);
        expect(find.text('Request Location'), findsNothing);
        expect(find.text('Localizing...'), findsNWidgets(2));
        expect(find.text('Stop'), findsOneWidget);

        await tester.tap(find.text('Stop'));
        await tester.pump();

        verify(() => mockRepository.stopLocation('gw-camper-1')).called(1);
      },
    );

    testWidgets(
      'renders coordinates and formatted timestamp when location is present',
      (tester) async {
        const startedAtMillis = 1760794200000;
        const gateway = Gateway(
          id: 'gw-camper-1',
          state: GatewayStates.connected,
          userId: 'user-1',
          location: GatewayLocation(
            exact: GatewayLocationPoint(
              datetime: 0,
              latitude: 42.5987,
              longitude: 0.5342,
            ),
            startedAt: startedAtMillis,
          ),
        );

        await pumpGatewayCard(tester, gateway);

        expect(find.text('42.5987, 0.5342'), findsOneWidget);
        expect(find.text(formatDateTime(startedAtMillis)), findsOneWidget);
        expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      },
    );
  });
}
