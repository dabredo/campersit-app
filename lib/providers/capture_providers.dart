import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/capture.dart';
import '../repositories/capture_repository.dart';
import 'auth_providers.dart';

typedef CameraCapturesKey = ({String gatewayId, String sensorId});

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepository();
});

final cameraCapturesProvider =
    StreamProvider.autoDispose.family<List<Capture>, CameraCapturesKey>((
  ref,
  key,
) {
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
