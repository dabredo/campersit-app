import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../repositories/gateway_repository.dart';
import 'async_action_helper.dart';
import 'auth_providers.dart';

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

class AddGatewayController extends AsyncActionNotifier {
  Future<bool> addGateway(String gatewayId) => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).addGateway(gatewayId),
    successMessage: 'Gateway added successfully',
  );
}

final deleteGatewayControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DeleteGatewayController, void, String>(DeleteGatewayController.new);

class DeleteGatewayController extends AsyncActionNotifier {
  DeleteGatewayController(this.gatewayId);

  final String gatewayId;

  Future<bool> deleteGateway() => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).deleteGateway(gatewayId),
    successMessage: 'Gateway deleted',
  );
}

final armGatewayControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ArmGatewayController, void, String>(ArmGatewayController.new);

class ArmGatewayController extends AsyncActionNotifier {
  ArmGatewayController(this.gatewayId);

  final String gatewayId;

  Future<bool> armGateway() => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).armGateway(gatewayId),
    successMessage: 'Gateway armed',
  );
}

final disarmGatewayControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DisarmGatewayController, void, String>(DisarmGatewayController.new);

class DisarmGatewayController extends AsyncActionNotifier {
  DisarmGatewayController(this.gatewayId);

  final String gatewayId;

  Future<bool> disarmGateway() => runNotifiedAction(
    () => ref.read(gatewayRepositoryProvider).disarmGateway(gatewayId),
    successMessage: 'Gateway disarmed',
  );
}

final toggleLocalizationControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ToggleLocalizationController, void, String>(
      ToggleLocalizationController.new,
    );

class ToggleLocalizationController extends AsyncActionNotifier {
  ToggleLocalizationController(this.gatewayId);

  final String gatewayId;

  Future<bool> toggleLocalization({required bool isCurrentlyLocalizing}) =>
      runNotifiedAction(() async {
        final repository = ref.read(gatewayRepositoryProvider);
        if (isCurrentlyLocalizing) {
          await repository.stopLocation(gatewayId);
        } else {
          await repository.requestLocation(gatewayId);
        }
      });
}

