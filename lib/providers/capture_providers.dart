import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/capture.dart';
import '../repositories/capture_repository.dart';
import 'async_action_helper.dart';
import 'auth_providers.dart';

typedef CameraCapturesKey = ({String gatewayId, String sensorId});

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepository();
});

final cameraCapturesProvider = StreamProvider.autoDispose
    .family<List<Capture>, CameraCapturesKey>((ref, key) {
      final repository = ref.watch(captureRepositoryProvider);
      return watchAuthenticatedUserStream(
        ref,
        emptyValue: const [],
        watch: (userId) => repository.watchCameraCaptures(
          userId: userId,
          deviceId: key.gatewayId,
          sensorId: key.sensorId,
        ),
      );
    });

final deleteCaptureControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DeleteCaptureController, void, String>(DeleteCaptureController.new);

class DeleteCaptureController extends AsyncActionNotifier {
  DeleteCaptureController(this.captureId);

  final String captureId;

  Future<bool> deleteCapture() => runNotifiedAction(
    () => ref.read(captureRepositoryProvider).deleteCapture(captureId),
    successMessage: 'Capture deleted successfully',
  );
}
