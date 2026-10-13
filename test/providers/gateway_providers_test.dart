import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockGatewayRepository();
    container = ProviderContainer(
      overrides: [
        gatewayRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DeleteGatewayController', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';

    test('returns true and shows success notification on successful delete',
        () async {
      when(
        () => mockRepository.deleteGateway(testGatewayId),
      ).thenAnswer((_) async {});

      final result = await container
          .read(deleteGatewayControllerProvider(testGatewayId).notifier)
          .deleteGateway();

      expect(result, isTrue);
      verify(() => mockRepository.deleteGateway(testGatewayId)).called(1);
    });

    test('returns false and shows error notification when repository throws',
        () async {
      when(
        () => mockRepository.deleteGateway(testGatewayId),
      ).thenThrow(Exception('Network error'));

      final result = await container
          .read(deleteGatewayControllerProvider(testGatewayId).notifier)
          .deleteGateway();

      expect(result, isFalse);
      final controllerState =
          container.read(deleteGatewayControllerProvider(testGatewayId));
      expect(controllerState.hasError, isTrue);
    });

    test('state transitions to loading then settles after delete', () async {
      when(
        () => mockRepository.deleteGateway(testGatewayId),
      ).thenAnswer((_) async {});

      final future = container
          .read(deleteGatewayControllerProvider(testGatewayId).notifier)
          .deleteGateway();

      expect(
        container.read(deleteGatewayControllerProvider(testGatewayId)),
        isA<AsyncLoading>(),
      );

      await future;

      expect(
        container.read(deleteGatewayControllerProvider(testGatewayId)),
        isA<AsyncData<void>>(),
      );
    });
  });

  group('ToggleLocalizationController', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';

    test('calls requestLocation when gateway is not currently localizing',
        () async {
      when(
        () => mockRepository.requestLocation(testGatewayId),
      ).thenAnswer((_) async {});

      final result = await container
          .read(toggleLocalizationControllerProvider(testGatewayId).notifier)
          .toggleLocalization(isCurrentlyLocalizing: false);

      expect(result, isTrue);
      verify(() => mockRepository.requestLocation(testGatewayId)).called(1);
      verifyNever(() => mockRepository.stopLocation(any()));
    });

    test('calls stopLocation when gateway is currently localizing', () async {
      when(
        () => mockRepository.stopLocation(testGatewayId),
      ).thenAnswer((_) async {});

      final result = await container
          .read(toggleLocalizationControllerProvider(testGatewayId).notifier)
          .toggleLocalization(isCurrentlyLocalizing: true);

      expect(result, isTrue);
      verify(() => mockRepository.stopLocation(testGatewayId)).called(1);
      verifyNever(() => mockRepository.requestLocation(any()));
    });

    test('returns false and marks error state when repository throws', () async {
      when(
        () => mockRepository.requestLocation(testGatewayId),
      ).thenThrow(Exception('Timeout'));

      final result = await container
          .read(toggleLocalizationControllerProvider(testGatewayId).notifier)
          .toggleLocalization(isCurrentlyLocalizing: false);

      expect(result, isFalse);
      final controllerState = container
          .read(toggleLocalizationControllerProvider(testGatewayId));
      expect(controllerState.hasError, isTrue);
    });
  });

  group('Loading state isolation between controllers', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';

    test(
        'delete loading state does not affect toggle localization loading state',
        () async {
      when(
        () => mockRepository.deleteGateway(testGatewayId),
      ).thenAnswer((_) async {});

      final deleteFuture = container
          .read(deleteGatewayControllerProvider(testGatewayId).notifier)
          .deleteGateway();

      final isDeleteLoading =
          container.read(deleteGatewayControllerProvider(testGatewayId)).isLoading;
      final isToggleLoading = container
          .read(toggleLocalizationControllerProvider(testGatewayId))
          .isLoading;

      expect(isDeleteLoading, isTrue);
      expect(isToggleLoading, isFalse);

      await deleteFuture;
    });

    test(
        'toggle loading state does not affect delete loading state',
        () async {
      when(
        () => mockRepository.requestLocation(testGatewayId),
      ).thenAnswer((_) async {});

      final toggleFuture = container
          .read(toggleLocalizationControllerProvider(testGatewayId).notifier)
          .toggleLocalization(isCurrentlyLocalizing: false);

      final isDeleteLoading =
          container.read(deleteGatewayControllerProvider(testGatewayId)).isLoading;
      final isToggleLoading = container
          .read(toggleLocalizationControllerProvider(testGatewayId))
          .isLoading;

      expect(isToggleLoading, isTrue);
      expect(isDeleteLoading, isFalse);

      await toggleFuture;
    });
  });
}
