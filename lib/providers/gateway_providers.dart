import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../repositories/gateway_repository.dart';
import 'auth_providers.dart';
import 'notification_provider.dart';

final gatewayRepositoryProvider = Provider<GatewayRepository>((ref) {
  return GatewayRepository();
});

final userGatewaysProvider = StreamProvider<List<Gateway>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(gatewayRepositoryProvider);
  return repository.watchUserGateways(user.uid);
});

final singleGatewayProvider = StreamProvider.family<Gateway?, String>((
  ref,
  gatewayId,
) {
  final repository = ref.watch(gatewayRepositoryProvider);
  return repository.watchGateway(gatewayId);
});

final addGatewayControllerProvider =
    AsyncNotifierProvider.autoDispose<AddGatewayController, void>(
      AddGatewayController.new,
    );

class AddGatewayController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> addGateway(String gatewayId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gatewayRepositoryProvider);
      await repository.addGateway(gatewayId);
    });

    final error = state.error;
    if (error != null) {
      ref.read(notificationProvider.notifier).showError(error);
      return false;
    }

    ref
        .read(notificationProvider.notifier)
        .showSuccess('Gateway added successfully');
    return true;
  }
}

final deleteGatewayControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DeleteGatewayController, void, String>(DeleteGatewayController.new);

class DeleteGatewayController extends AsyncNotifier<void> {
  DeleteGatewayController(this.gatewayId);

  final String gatewayId;

  @override
  FutureOr<void> build() {}

  Future<bool> deleteGateway() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gatewayRepositoryProvider);
      await repository.deleteGateway(gatewayId);
    });

    final error = state.error;
    if (error != null) {
      ref.read(notificationProvider.notifier).showError(error);
      return false;
    }

    ref.read(notificationProvider.notifier).showSuccess('Gateway deleted');
    return true;
  }
}

final toggleLocalizationControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ToggleLocalizationController, void, String>(
      ToggleLocalizationController.new,
    );

class ToggleLocalizationController extends AsyncNotifier<void> {
  ToggleLocalizationController(this.gatewayId);

  final String gatewayId;

  @override
  FutureOr<void> build() {}

  Future<bool> toggleLocalization({required bool isCurrentlyLocalizing}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gatewayRepositoryProvider);
      if (isCurrentlyLocalizing) {
        await repository.stopLocation(gatewayId);
      } else {
        await repository.requestLocation(gatewayId);
      }
    });

    final error = state.error;
    if (error != null) {
      ref.read(notificationProvider.notifier).showError(error);
      return false;
    }

    return true;
  }
}

final updateSensorTagControllerProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateSensorTagController, void, String>(
      UpdateSensorTagController.new,
    );

class UpdateSensorTagController extends AsyncNotifier<void> {
  UpdateSensorTagController(this.gatewayId);

  final String gatewayId;

  @override
  FutureOr<void> build() {}

  Future<bool> updateTag({
    required String sensorId,
    required String tag,
  }) async {
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(gatewayRepositoryProvider);
        await repository.updateSensorTag(
          gatewayId: gatewayId,
          sensorId: sensorId,
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
    .family<DeleteSensorController, String?, String>(
      DeleteSensorController.new,
    );

class DeleteSensorController extends Notifier<String?> {
  DeleteSensorController(this.gatewayId);

  final String gatewayId;

  @override
  String? build() => null;

  Future<bool> deleteSensor(String sensorId) async {
    final link = ref.keepAlive();
    state = sensorId;
    try {
      final repository = ref.read(gatewayRepositoryProvider);
      await repository.deleteSensor(gatewayId: gatewayId, sensorId: sensorId);

      ref
          .read(notificationProvider.notifier)
          .showSuccess('Sensor unlinked successfully');
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

typedef SensorTargetKey = ({String gatewayId, String sensorId});

final requestSensorStateControllerProvider = NotifierProvider.autoDispose
    .family<RequestSensorStateController, SensorState?, SensorTargetKey>(
      RequestSensorStateController.new,
    );

class RequestSensorStateController extends Notifier<SensorState?> {
  RequestSensorStateController(this.key);

  final SensorTargetKey key;

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
