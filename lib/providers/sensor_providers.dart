import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensor.dart';
import 'gateway_providers.dart';
import 'notification_provider.dart';

typedef SensorKey = ({String gatewayId, String sensorId});

final updateSensorTagControllerProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateSensorTagController, void, SensorKey>(
      UpdateSensorTagController.new,
    );

class UpdateSensorTagController extends AsyncNotifier<void> {
  UpdateSensorTagController(this.key);

  final SensorKey key;

  @override
  FutureOr<void> build() {}

  Future<bool> updateTag(String tag) async {
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(gatewayRepositoryProvider);
        await repository.updateSensorTag(
          gatewayId: key.gatewayId,
          sensorId: key.sensorId,
          tag: tag,
        );
      });

      final error = state.error;
      if (error != null) {
        ref.read(notificationProvider.notifier).showError(error);
        return false;
      }

      ref.read(notificationProvider.notifier).showSuccess('Sensor tag updated');
      return true;
    } finally {
      link.close();
    }
  }
}

final addSensorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AddSensorController, void, String>(AddSensorController.new);

class AddSensorController extends AsyncNotifier<void> {
  AddSensorController(this.gatewayId);

  final String gatewayId;

  @override
  FutureOr<void> build() {}

  Future<bool> addSensor(String sensorId) async {
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(gatewayRepositoryProvider);
        await repository.addSensor(gatewayId: gatewayId, sensorId: sensorId);
      });

      final error = state.error;
      if (error != null) {
        ref.read(notificationProvider.notifier).showError(error);
        return false;
      }

      ref
          .read(notificationProvider.notifier)
          .showSuccess('Sensor added successfully');
      return true;
    } finally {
      link.close();
    }
  }
}

final deleteSensorControllerProvider = NotifierProvider.autoDispose
    .family<DeleteSensorController, bool, SensorKey>(
      DeleteSensorController.new,
    );

class DeleteSensorController extends Notifier<bool> {
  DeleteSensorController(this.key);

  final SensorKey key;

  @override
  bool build() => false;

  Future<bool> deleteSensor() async {
    final link = ref.keepAlive();
    state = true;
    try {
      final repository = ref.read(gatewayRepositoryProvider);
      await repository.deleteSensor(
        gatewayId: key.gatewayId,
        sensorId: key.sensorId,
      );

      ref
          .read(notificationProvider.notifier)
          .showSuccess('Sensor unlinked successfully');
      return true;
    } catch (error) {
      ref.read(notificationProvider.notifier).showError(error);
      return false;
    } finally {
      state = false;
      link.close();
    }
  }
}

final requestSensorStateControllerProvider = NotifierProvider.autoDispose
    .family<RequestSensorStateController, SensorState?, SensorKey>(
      RequestSensorStateController.new,
    );

class RequestSensorStateController extends Notifier<SensorState?> {
  RequestSensorStateController(this.key);

  final SensorKey key;

  @override
  SensorState? build() => null;

  Future<bool> requestState(SensorState targetState) async {
    final link = ref.keepAlive();
    state = targetState;
    try {
      final repository = ref.read(gatewayRepositoryProvider);
      await repository.sendRequestState(
        gatewayId: key.gatewayId,
        sensorId: key.sensorId,
        state: targetState,
      );

      ref
          .read(notificationProvider.notifier)
          .showSuccess('State update requested: ${targetState.label}');
      return true;
    } catch (error) {
      ref.read(notificationProvider.notifier).showError(error);
      return false;
    } finally {
      state = null;
      link.close();
    }
  }
}

typedef MotionActionKey = ({
  String gatewayId,
  String sensorId,
  String actuatorId,
});

final updateMotionActionControllerProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateMotionActionController, void, MotionActionKey>(
      UpdateMotionActionController.new,
    );

class UpdateMotionActionController extends AsyncNotifier<void> {
  UpdateMotionActionController(this.key);

  final MotionActionKey key;

  @override
  FutureOr<void> build() {}

  Future<bool> setActionEnabled(bool enabled) async {
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(gatewayRepositoryProvider);
        await repository.updateSensorAction(
          gatewayId: key.gatewayId,
          sensorId: key.sensorId,
          actuatorId: key.actuatorId,
          enabled: enabled,
        );
      });

      final error = state.error;
      if (error != null) {
        ref.read(notificationProvider.notifier).showError(error);
        return false;
      }

      final message =
          enabled ? 'Actuator action linked' : 'Actuator action unlinked';
      ref.read(notificationProvider.notifier).showSuccess(message);
      return true;
    } finally {
      link.close();
    }
  }
}

