import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/add_sensor_bottom_sheet.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  const gatewayId = 'AA:BB:CC:DD:EE:FF';
  late MockGatewayRepository mockRepository;

  setUp(() {
    mockRepository = MockGatewayRepository();
  });

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        gatewayRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AddSensorBottomSheet(gatewayId: gatewayId),
        ),
      ),
    );
  }

  group('AddSensorBottomSheet', () {
    testWidgets('renders input field and submit button', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Add Sensor'), findsNWidgets(2)); // Title and button
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Sensor ID'), findsOneWidget);
    });

    testWidgets('validates empty sensor ID on submit', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Sensor'));
      await tester.pump();

      expect(find.text('Please enter your Sensor ID'), findsOneWidget);
      verifyNever(
        () => mockRepository.addSensor(
          gatewayId: any(named: 'gatewayId'),
          sensorId: any(named: 'sensorId'),
        ),
      );
    });

    testWidgets('calls addSensor on submit with formatted MAC sensor ID', (
      tester,
    ) async {
      when(
        () => mockRepository.addSensor(
          gatewayId: gatewayId,
          sensorId: 'AA:BB:CC:11:22:33',
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextFormField), 'aabbcc112233');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Sensor'));
      await tester.pump();

      verify(
        () => mockRepository.addSensor(
          gatewayId: gatewayId,
          sensorId: 'AA:BB:CC:11:22:33',
        ),
      ).called(1);
    });
  });
}
