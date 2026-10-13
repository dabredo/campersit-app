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

    if (state.hasError) {
      ref.read(notificationProvider.notifier).showError(state.error!);
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

    if (state.hasError) {
      ref.read(notificationProvider.notifier).showError(state.error!);
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

    if (state.hasError) {
      ref.read(notificationProvider.notifier).showError(state.error!);
      return false;
    }

    return true;
  }
}
