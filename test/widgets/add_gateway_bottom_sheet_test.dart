import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/add_gateway_bottom_sheet.dart';

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
          body: AddGatewayBottomSheet(),
        ),
      ),
    );
  }

  group('AddGatewayBottomSheet', () {
    testWidgets('renders input field and submit button', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Add Gateway'), findsNWidgets(2)); // Title and button
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Gateway ID'), findsOneWidget);
    });

    testWidgets('validates empty gateway ID on submit', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Gateway'));
      await tester.pump();

      expect(find.text('Please enter your Gateway ID'), findsOneWidget);
      verifyNever(() => mockRepository.addGateway(any()));
    });

    testWidgets('calls addGateway on submit with formatted MAC ID', (
      tester,
    ) async {
      when(
        () => mockRepository.addGateway(gatewayId),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextFormField), 'aabbccddeeff');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Gateway'));
      await tester.pump();

      verify(() => mockRepository.addGateway(gatewayId)).called(1);
    });
  });
}
