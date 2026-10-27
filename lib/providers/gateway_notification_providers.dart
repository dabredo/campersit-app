import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway_notification.dart';
import '../repositories/notification_repository.dart';
import '../services/fcm_service.dart';
import 'gateway_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return FcmService(repository: repository);
});

final userNotificationsProvider =
    StreamProvider<List<GatewayNotification>>((ref) {
  final gateways = ref.watch(userGatewaysProvider).value;
  if (gateways == null || gateways.isEmpty) {
    return Stream.value(const []);
  }

  final gatewayIds = gateways.map((g) => g.id).toList();
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchNotificationsForGateways(gatewayIds);
});

final gatewayNotificationsProvider =
    StreamProvider.family<List<GatewayNotification>, String>((ref, gatewayId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchGatewayNotifications(gatewayId);
});

class LastSeenNotificationTimestampNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void markAsSeen([int? timestamp]) {
    state = timestamp ?? DateTime.now().millisecondsSinceEpoch;
  }
}

final lastSeenNotificationTimestampProvider =
    NotifierProvider<LastSeenNotificationTimestampNotifier, int>(
  LastSeenNotificationTimestampNotifier.new,
);

final userNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider).value ?? const [];
  if (notifications.isEmpty) return 0;

  final lastSeen = ref.watch(lastSeenNotificationTimestampProvider);
  final cutoff = lastSeen > 0
      ? lastSeen
      : DateTime.now().subtract(const Duration(hours: 24)).millisecondsSinceEpoch;

  return notifications.where((item) => item.createdAt > cutoff).length;
});
