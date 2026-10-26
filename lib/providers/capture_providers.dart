import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/capture.dart';
import '../repositories/capture_repository.dart';
import 'auth_providers.dart';
import 'notification_provider.dart';

typedef CameraCapturesKey = ({String gatewayId, String sensorId});

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepository();
});

final cameraCapturesProvider = StreamProvider.autoDispose
    .family<List<Capture>, CameraCapturesKey>((ref, key) {
      final user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream.value([]);
      }

      final repository = ref.watch(captureRepositoryProvider);
      return repository.watchCameraCaptures(
        userId: user.uid,
        deviceId: key.gatewayId,
        sensorId: key.sensorId,
      );
    });

final deleteCaptureControllerProvider = NotifierProvider.autoDispose
    .family<DeleteCaptureController, bool, String>(DeleteCaptureController.new);

class DeleteCaptureController extends Notifier<bool> {
  DeleteCaptureController(this.captureId);

  final String captureId;

  @override
  bool build() => false;

  Future<bool> deleteCapture() async {
    final link = ref.keepAlive();
    state = true;
    try {
      final repository = ref.read(captureRepositoryProvider);
      await repository.deleteCapture(captureId);

      ref
          .read(notificationProvider.notifier)
          .showSuccess('Capture deleted successfully');
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
