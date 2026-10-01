import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/app_notification.dart';
import 'package:campersit_app/providers/notification_provider.dart';

void main() {
  group('NotificationNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final initialNotification = container.read(notificationProvider);
      expect(initialNotification, isNull);
    });

    test('showError sets error notification with formatted message', () {
      final authException = FirebaseAuthException(code: 'wrong-password');
      container.read(notificationProvider.notifier).showError(authException);

      final state = container.read(notificationProvider);
      expect(state, isNotNull);
      expect(state!.type, equals(NotificationType.error));
      expect(state.message, equals('Invalid email or password. Please try again.'));
      expect(state.duration, equals(const Duration(seconds: 4)));
      expect(state.id, isNotEmpty);
    });

    test('showSuccess sets success notification', () {
      container
          .read(notificationProvider.notifier)
          .showSuccess('Device paired successfully');

      final state = container.read(notificationProvider);
      expect(state, isNotNull);
      expect(state!.type, equals(NotificationType.success));
      expect(state.message, equals('Device paired successfully'));
      expect(state.duration, equals(const Duration(seconds: 4)));
    });

    test('showWarning sets warning notification with custom duration', () {
      const customDuration = Duration(seconds: 8);
      container.read(notificationProvider.notifier).showWarning(
            'Battery level below 15%',
            duration: customDuration,
          );

      final state = container.read(notificationProvider);
      expect(state, isNotNull);
      expect(state!.type, equals(NotificationType.warning));
      expect(state.message, equals('Battery level below 15%'));
      expect(state.duration, equals(customDuration));
    });

    test('showInfo sets info notification', () {
      container
          .read(notificationProvider.notifier)
          .showInfo('Firmware update available');

      final state = container.read(notificationProvider);
      expect(state, isNotNull);
      expect(state!.type, equals(NotificationType.info));
      expect(state.message, equals('Firmware update available'));
    });

    test('dismiss resets state to null', () {
      container
          .read(notificationProvider.notifier)
          .showInfo('Temporary notice');
      expect(container.read(notificationProvider), isNotNull);

      container.read(notificationProvider.notifier).dismiss();
      expect(container.read(notificationProvider), isNull);
    });

    test('consecutive notifications generate unique IDs', () {
      container.read(notificationProvider.notifier).showInfo('First');
      final firstId = container.read(notificationProvider)!.id;

      container.read(notificationProvider.notifier).showInfo('Second');
      final secondId = container.read(notificationProvider)!.id;

      expect(firstId, isNot(equals(secondId)));
    });
  });
}
