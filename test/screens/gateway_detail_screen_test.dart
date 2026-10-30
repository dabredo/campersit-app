import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/screens/gateway_detail_screen.dart';
import 'package:campersit_app/utils/date_time_formatter.dart';
import 'package:campersit_app/widgets/gateway/sensors_sliver.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  const gatewayId = 'AA:BB:CC:DD:EE:FF';
  const seenAtMillis = 1760790600000;

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
    testWidgets('renders status, last seen, and alarms', (
      tester,
    ) async {
      final gateway = buildGateway(
        alerts: {'door': 'open'},
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

    testWidgets('shows formatted error message when stream emits error', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer(
        (_) => Stream.error(Exception('Failed to fetch gateway')),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Error loading gateway details:\nAn unexpected error occurred. Please try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('falls back to initial gateway while loading', (tester) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => const Stream.empty());

      await pumpScreen(tester, initialGateway: buildGateway(state: 'l'));

      expect(find.text('Localizing...'), findsOneWidget);
    });

    testWidgets('opens add sensor bottom sheet when tapping add sensor button', (
      tester,
    ) async {
      when(
        () => mockRepository.watchGateway(gatewayId),
      ).thenAnswer((_) => Stream.value(buildGateway()));

      await pumpScreen(tester);
      await tester.pump();
      await tester.ensureVisible(find.byType(AddSensorCard));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AddSensorCard));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Sensor ID'), findsOneWidget);
    });
  });
}

