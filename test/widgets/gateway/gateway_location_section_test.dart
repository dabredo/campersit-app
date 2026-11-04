import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/gateway/gateway_location_section.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockGatewayRepository;

  setUp(() {
    mockGatewayRepository = MockGatewayRepository();
  });

  testWidgets('GatewayLocationSection renders GPS Location and requests location', (
    tester,
  ) async {
    when(
      () => mockGatewayRepository.requestLocation('GW-1'),
    ).thenAnswer((_) async {});

    const gateway = Gateway(
      id: 'GW-1',
      state: GatewayStates.connected,
      userId: 'user-1',
      sensors: [],
      alerts: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockGatewayRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: GatewayLocationSection(gateway: gateway)),
        ),
      ),
    );

    expect(find.text('GPS Location'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('request_location_GW-1')));
    await tester.pumpAndSettle();

    verify(() => mockGatewayRepository.requestLocation('GW-1')).called(1);
  });
}
