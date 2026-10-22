import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/screens/gateway_detail_screen.dart';
import 'package:campersit_app/utils/date_time_formatter.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  const gatewayId = 'AA:BB:CC:DD:EE:FF';
  const seenAtMillis = 1760790600000;
  const locatingSinceMillis = 1760794200000;

  late MockGatewayRepository mockRepository;

  setUp(() {
    mockRepository = MockGatewayRepository();
  });

  Future<void> pumpScreen(WidgetTester tester, {Gateway? initialGateway}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: GatewayDetailScreen(
            gatewayId: gatewayId,
            initialGateway: initialGateway,
          ),
        ),
      ),
    );
  }

  Gateway buildGateway({
    String state = 'c',
    List<Sensor> sensors = const [],
    Map<String, Object?> alerts = const {},
    GatewayLocation? location,
  }) {
    return Gateway(
      id: gatewayId,
      state: state,
      seenAt: seenAtMillis,
      userId: 'user-1',
      alerts: alerts,
      location: location,
      sensors: sensors,
    );
  }

  group('GatewayDetailScreen', () {
    testWidgets('renders status, last seen, alarms and location details', (
      tester,
    ) async {
      final gateway = buildGateway(
        alerts: {'door': 'open'},
        location: GatewayLocation(
          exact: GatewayLocationPoint(
            datetime: 0,
            latitude: 40.5,
            longitude: -3.7,
          ),
          startedAt: locatingSinceMillis,
        ),
      );
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(gateway));

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text(gatewayId), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text(formatDateTime(seenAtMillis)), findsOneWidget);
      expect(find.text('- door: open'), findsOneWidget);
      expect(find.text('40.5, -3.7'), findsOneWidget);
      expect(find.text(formatDateTime(locatingSinceMillis)), findsOneWidget);
      expect(find.text('Request Location'), findsOneWidget);
    });

    testWidgets('shows empty sensors placeholder when there are no sensors', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(buildGateway()));

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('No Sensors Configured'), findsOneWidget);
    });

    testWidgets('renders one card per sensor with count label', (
      tester,
    ) async {
      final gateway = buildGateway(
        sensors: const [
          Sensor(id: 'cam-1', type: SensorType.camera, tag: 'Front Camera'),
        ],
      );
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(gateway));

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Front Camera'), findsOneWidget);
    });

    testWidgets('does not render sensors that have unpaired state', (
      tester,
    ) async {
      final gateway = buildGateway(
        sensors: const [
          Sensor(id: 'cam-1', type: SensorType.camera, tag: 'Front Camera'),
          Sensor(
            id: 'motion-1',
            type: SensorType.motion,
            state: SensorState.unpaired,
            tag: 'Old Motion Sensor',
          ),
        ],
      );
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(gateway));

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Front Camera'), findsOneWidget);
      expect(find.text('Old Motion Sensor'), findsNothing);
    });

    testWidgets('shows not found message when gateway is missing', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(null));

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('Gateway not found.'), findsOneWidget);
    });

    testWidgets('falls back to initial gateway while loading', (tester) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => const Stream.empty());

      await pumpScreen(tester, initialGateway: buildGateway(state: 'l'));

      expect(find.text('Localizing...'), findsOneWidget);
      expect(find.text('Stop Localizing'), findsOneWidget);
    });

    testWidgets('requests location when tapping the location button', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(buildGateway()));
      when(
        () => mockRepository.requestLocation(gatewayId),
      ).thenAnswer((_) async {});

      await pumpScreen(tester);
      await tester.pump();
      await tester.tap(find.text('Request Location'));
      await tester.pump();

      verify(() => mockRepository.requestLocation(gatewayId)).called(1);
    });

    testWidgets('opens add sensor bottom sheet when tapping add sensor button', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(buildGateway()));

      await pumpScreen(tester);
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Sensor ID'), findsOneWidget);
    });
  });
}

