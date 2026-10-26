import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/providers/sensor_providers.dart';
import 'package:campersit_app/repositories/gateway_repository.dart';

class MockGatewayRepository extends Mock implements GatewayRepository {}

void main() {
  late MockGatewayRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockGatewayRepository();
    container = ProviderContainer(
      overrides: [gatewayRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('UpdateSensorTagController', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';
    const testSensorId = 'sensor-1';
    const testKey = (gatewayId: testGatewayId, sensorId: testSensorId);

    test(
      'returns true and shows success notification on successful update',
      () async {
        when(
          () => mockRepository.updateSensorTag(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
            tag: 'Living Room',
          ),
        ).thenAnswer((_) async {});

        final result = await container
            .read(updateSensorTagControllerProvider(testKey).notifier)
            .updateTag('Living Room');

        expect(result, isTrue);
        verify(
          () => mockRepository.updateSensorTag(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
            tag: 'Living Room',
          ),
        ).called(1);
      },
    );

    test('returns false and captures error when repository throws', () async {
      when(
        () => mockRepository.updateSensorTag(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          tag: 'Living Room',
        ),
      ).thenThrow(Exception('Firestore update failed'));

      final result = await container
          .read(updateSensorTagControllerProvider(testKey).notifier)
          .updateTag('Living Room');

      expect(result, isFalse);
      final controllerState = container.read(
        updateSensorTagControllerProvider(testKey),
      );
      expect(controllerState.hasError, isTrue);
    });

    test('state transitions to loading then settles after update', () async {
      when(
        () => mockRepository.updateSensorTag(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          tag: 'Living Room',
        ),
      ).thenAnswer((_) async {});

      final future = container
          .read(updateSensorTagControllerProvider(testKey).notifier)
          .updateTag('Living Room');

      expect(
        container.read(updateSensorTagControllerProvider(testKey)),
        isA<AsyncLoading>(),
      );

      await future;

      expect(
        container.read(updateSensorTagControllerProvider(testKey)),
        isA<AsyncData<void>>(),
      );
    });
  });

  group('AddSensorController', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';
    const testSensorId = 'sensor_01';

    test(
      'returns true and shows success notification on successful add',
      () async {
        when(
          () => mockRepository.addSensor(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
          ),
        ).thenAnswer((_) async {});

        final result = await container
            .read(addSensorControllerProvider(testGatewayId).notifier)
            .addSensor(testSensorId);

        expect(result, isTrue);
        verify(
          () => mockRepository.addSensor(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
          ),
        ).called(1);
      },
    );

    test('returns false and captures error when repository throws', () async {
      when(
        () => mockRepository.addSensor(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
        ),
      ).thenThrow(Exception('Functions call failed'));

      final result = await container
          .read(addSensorControllerProvider(testGatewayId).notifier)
          .addSensor(testSensorId);

      expect(result, isFalse);
      final controllerState = container.read(
        addSensorControllerProvider(testGatewayId),
      );
      expect(controllerState.hasError, isTrue);
    });

    test('state transitions to loading then settles after add', () async {
      when(
        () => mockRepository.addSensor(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
        ),
      ).thenAnswer((_) async {});

      final future = container
          .read(addSensorControllerProvider(testGatewayId).notifier)
          .addSensor(testSensorId);

      expect(
        container.read(addSensorControllerProvider(testGatewayId)),
        isA<AsyncLoading>(),
      );

      await future;

      expect(
        container.read(addSensorControllerProvider(testGatewayId)),
        isA<AsyncData<void>>(),
      );
    });
  });

  group('DeleteSensorController', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';
    const testSensorId = 'sensor_01';
    const testKey = (gatewayId: testGatewayId, sensorId: testSensorId);

    test(
      'returns true and shows success notification on successful delete',
      () async {
        when(
          () => mockRepository.deleteSensor(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
          ),
        ).thenAnswer((_) async {});

        final result = await container
            .read(deleteSensorControllerProvider(testKey).notifier)
            .deleteSensor();

        expect(result, isTrue);
        verify(
          () => mockRepository.deleteSensor(
            gatewayId: testGatewayId,
            sensorId: testSensorId,
          ),
        ).called(1);
      },
    );

    test('returns false and resets state to false when repository throws', () async {
      when(
        () => mockRepository.deleteSensor(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
        ),
      ).thenThrow(Exception('Functions call failed'));

      final result = await container
          .read(deleteSensorControllerProvider(testKey).notifier)
          .deleteSensor();

      expect(result, isFalse);
      final controllerState = container.read(
        deleteSensorControllerProvider(testKey),
      );
      expect(controllerState, isFalse);
    });

    test('sets deleting state to true while deleting and clears on completion', () async {
      when(
        () => mockRepository.deleteSensor(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
        ),
      ).thenAnswer((_) async {});

      final future = container
          .read(deleteSensorControllerProvider(testKey).notifier)
          .deleteSensor();

      expect(
        container.read(deleteSensorControllerProvider(testKey)),
        isTrue,
      );

      await future;

      expect(
        container.read(deleteSensorControllerProvider(testKey)),
        isFalse,
      );
    });
  });

  group('RequestSensorStateController Tests', () {
    const testGatewayId = 'AA:BB:CC:DD:EE:FF';
    const testSensorId = 'sensor-123';
    const testKey = (gatewayId: testGatewayId, sensorId: testSensorId);

    test('successfully sends state request and shows success notification', () async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          state: SensorState.enabled,
        ),
      ).thenAnswer((_) async {});

      final result = await container
          .read(requestSensorStateControllerProvider(testKey).notifier)
          .requestState(SensorState.enabled);

      expect(result, isTrue);
      verify(
        () => mockRepository.sendRequestState(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          state: SensorState.enabled,
        ),
      ).called(1);
    });

    test('returns false and resets state to null when repository throws', () async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          state: SensorState.started,
        ),
      ).thenThrow(Exception('Failed to send state'));

      final result = await container
          .read(requestSensorStateControllerProvider(testKey).notifier)
          .requestState(SensorState.started);

      expect(result, isFalse);
      final controllerState = container.read(
        requestSensorStateControllerProvider(testKey),
      );
      expect(controllerState, isNull);
    });

    test('sets loading target state during request and clears on completion', () async {
      when(
        () => mockRepository.sendRequestState(
          gatewayId: testGatewayId,
          sensorId: testSensorId,
          state: SensorState.enabled,
        ),
      ).thenAnswer((_) async {});

      final future = container
          .read(requestSensorStateControllerProvider(testKey).notifier)
          .requestState(SensorState.enabled);

      expect(
        container.read(requestSensorStateControllerProvider(testKey)),
        equals(SensorState.enabled),
      );

      await future;

      expect(
        container.read(requestSensorStateControllerProvider(testKey)),
        isNull,
      );
    });
  });
}
