import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/models/gateway_notification.dart';
import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/repositories/notification_repository.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  group('Gateway Notification Providers', () {
    test('userNotificationsProvider returns empty list when user has no gateways', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepository),
          userGatewaysProvider.overrideWith(
            (ref) => Stream.value(<Gateway>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifications = await container.read(userNotificationsProvider.future);
      expect(notifications, isEmpty);
      verifyNever(() => mockRepository.watchNotificationsForGateways(any()));
    });

    test('userNotificationsProvider watches notifications for user gateway IDs', () async {
      final sampleGateway = Gateway(
        id: 'gw_1',
        state: GatewayStates.connected,
        userId: 'user_1',
        alerts: const {},
      );

      const sampleNotification = GatewayNotification(
        id: 'notif_1',
        type: 'sensor-triggered',
        gatewayId: 'gw_1',
        createdAt: 1778320000000,
      );

      when(() => mockRepository.watchNotificationsForGateways(['gw_1']))
          .thenAnswer((_) => Stream.value([sampleNotification]));

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepository),
          userGatewaysProvider.overrideWith(
            (ref) => Stream.value([sampleGateway]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      // Wait for userGatewaysProvider to emit the gateway so userNotificationsProvider updates
      await container.read(userGatewaysProvider.future);

      final notifications = await container.read(userNotificationsProvider.future);
      expect(notifications.length, equals(1));
      expect(notifications.first.id, equals('notif_1'));
      verify(() => mockRepository.watchNotificationsForGateways(['gw_1'])).called(1);
    });

    test('gatewayNotificationsProvider watches single gateway notifications', () async {
      const sampleNotification = GatewayNotification(
        id: 'notif_2',
        type: 'device-initializing',
        gatewayId: 'gw_2',
        createdAt: 1778320000000,
      );

      when(() => mockRepository.watchGatewayNotifications('gw_2'))
          .thenAnswer((_) => Stream.value([sampleNotification]));

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        gatewayNotificationsProvider('gw_2'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifications =
          await container.read(gatewayNotificationsProvider('gw_2').future);
      expect(notifications.length, equals(1));
      expect(notifications.first.id, equals('notif_2'));
      verify(() => mockRepository.watchGatewayNotifications('gw_2')).called(1);
    });

    test('userNotificationsCountProvider counts only notifications from the last 24 hours', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final recentNotif = GatewayNotification(
        id: 'recent',
        type: 'sensor-triggered',
        gatewayId: 'gw_1',
        createdAt: now - const Duration(hours: 2).inMilliseconds,
      );
      final oldNotif = GatewayNotification(
        id: 'old',
        type: 'sensor-triggered',
        gatewayId: 'gw_1',
        createdAt: now - const Duration(days: 3).inMilliseconds,
      );

      final container = ProviderContainer(
        overrides: [
          userNotificationsProvider.overrideWith(
            (ref) => Stream.value([recentNotif, oldNotif]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(userNotificationsProvider.future);

      final count = container.read(userNotificationsCountProvider);
      expect(count, equals(1));
    });

    test('userNotificationsCountProvider resets count when notifications are marked as seen', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final recentNotif = GatewayNotification(
        id: 'recent',
        type: 'sensor-triggered',
        gatewayId: 'gw_1',
        createdAt: now - const Duration(hours: 1).inMilliseconds,
      );

      final container = ProviderContainer(
        overrides: [
          userNotificationsProvider.overrideWith(
            (ref) => Stream.value([recentNotif]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(userNotificationsProvider.future);
      expect(container.read(userNotificationsCountProvider), equals(1));

      container.read(lastSeenNotificationTimestampProvider.notifier).markAsSeen();

      expect(container.read(userNotificationsCountProvider), equals(0));
    });
  });
}
