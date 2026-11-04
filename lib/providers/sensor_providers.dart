import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensor.dart';
import 'async_action_helper.dart';
import 'gateway_providers.dart';
import 'notification_provider.dart';

typedef SensorKey = ({String gatewayId, String sensorId});

final updateSensorTagControllerProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateSensorTagController, void, SensorKey>(
      UpdateSensorTagController.new,
    );

class UpdateSensorTagController extends AsyncActionNotifier {
  UpdateSensorTagController(this.key);

  final SensorKey key;

  Future<bool> updateTag(String tag) => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).updateSensorTag(
          gatewayId: key.gatewayId,
          sensorId: key.sensorId,
          tag: tag,
        ),
    successMessage: 'Sensor tag updated',
  );
}

final addSensorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AddSensorController, void, String>(AddSensorController.new);

class AddSensorController extends AsyncActionNotifier {
  AddSensorController(this.gatewayId);

  final String gatewayId;

  Future<bool> addSensor(String sensorId) => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).addSensor(
          gatewayId: gatewayId,
          sensorId: sensorId,
        ),
    successMessage: 'Sensor added successfully',
  );
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

class UpdateMotionActionController extends AsyncActionNotifier {
  UpdateMotionActionController(this.key);

  final MotionActionKey key;

  Future<bool> setActionEnabled(bool enabled) => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).updateSensorAction(
          gatewayId: key.gatewayId,
          sensorId: key.sensorId,
          actuatorId: key.actuatorId,
          enabled: enabled,
        ),
    successMessage:
        enabled ? 'Actuator action linked' : 'Actuator action unlinked',
  );
}

