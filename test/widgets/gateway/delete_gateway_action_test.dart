import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';
import 'package:campersit_app/widgets/gateway/delete_gateway_action.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockGatewayRepository;

  setUp(() {
    mockGatewayRepository = MockGatewayRepository();
  });

  testWidgets('DeleteGatewayAction confirms and deletes gateway', (
    tester,
  ) async {
    when(
      () => mockGatewayRepository.deleteGateway('GW-1'),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gatewayRepositoryProvider.overrideWithValue(mockGatewayRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DeleteGatewayAction(gatewayId: 'GW-1')),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('delete_gateway_GW-1')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Gateway'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => mockGatewayRepository.deleteGateway('GW-1')).called(1);
  });
}

