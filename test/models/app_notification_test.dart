import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/app_notification.dart';

void main() {
  group('AppNotification Model Tests', () {
    test('creates instance with default duration of 4 seconds', () {
      final notification = AppNotification(
        id: 'notification-1',
        message: 'System operational',
        type: NotificationType.success,
      );

      expect(notification.id, equals('notification-1'));
      expect(notification.message, equals('System operational'));
      expect(notification.type, equals(NotificationType.success));
      expect(notification.duration, equals(const Duration(seconds: 4)));
    });

    test('creates instance with custom duration', () {
      const customDuration = Duration(seconds: 10);
      final notification = AppNotification(
        id: 'notification-2',
        message: 'Warning: sensor delay',
        type: NotificationType.warning,
        duration: customDuration,
      );

      expect(notification.duration, equals(customDuration));
    });

    test('supports all notification types', () {
      final success = AppNotification(
        id: '1',
        message: 'Success',
        type: NotificationType.success,
      );
      final error = AppNotification(
        id: '2',
        message: 'Error',
        type: NotificationType.error,
      );
      final warning = AppNotification(
        id: '3',
        message: 'Warning',
        type: NotificationType.warning,
      );
      final info = AppNotification(
        id: '4',
        message: 'Info',
        type: NotificationType.info,
      );

      expect(success.type, equals(NotificationType.success));
      expect(error.type, equals(NotificationType.error));
      expect(warning.type, equals(NotificationType.warning));
      expect(info.type, equals(NotificationType.info));
    });
  });
}
