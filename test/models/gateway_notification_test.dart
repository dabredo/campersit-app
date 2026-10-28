import 'package:campersit_app/models/gateway_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GatewayNotification Model Tests', () {
    test('parses notification correctly fromMap with all fields', () {
      final map = {
        'type': 'sensor-battery-low',
        'gatewayId': '08:A6:F7:9E:B3:70',
        'sensorId': 'EC:E3:34:15:F3:8C',
        'createdAt': 1778320057112,
        'sentAt': 1778320058376,
      };

      final notification = GatewayNotification.fromMap('notif_01', map);

      expect(notification.id, equals('notif_01'));
      expect(notification.type, equals('sensor-battery-low'));
      expect(notification.gatewayId, equals('08:A6:F7:9E:B3:70'));
      expect(notification.sensorId, equals('EC:E3:34:15:F3:8C'));
      expect(notification.createdAt, equals(1778320057112));
      expect(notification.sentAt, equals(1778320058376));
      expect(notification.isSensorRelated, isTrue);
      expect(notification.typeLabel, equals('Sensor Battery Low'));
      expect(notification.definition.title, equals('Sensor Battery Low'));
    });

    test('parses gateway-only notification correctly fromMap', () {
      final map = {
        'type': 'device-initializing',
        'gatewayId': '08:A6:F7:9E:B3:70',
        'createdAt': 1791976450999,
      };

      final notification = GatewayNotification.fromMap('notif_02', map);

      expect(notification.id, equals('notif_02'));
      expect(notification.type, equals('device-initializing'));
      expect(notification.gatewayId, equals('08:A6:F7:9E:B3:70'));
      expect(notification.sensorId, isNull);
      expect(notification.createdAt, equals(1791976450999));
      expect(notification.sentAt, isNull);
      expect(notification.isSensorRelated, isFalse);
      expect(notification.typeLabel, equals('Gateway Initializing'));

      const emptySensorNotification = GatewayNotification(
        id: 'notif_02b',
        type: 'device-initializing',
        gatewayId: '08:A6:F7:9E:B3:70',
        sensorId: '',
        createdAt: 1791976450999,
      );
      expect(emptySensorNotification.isSensorRelated, isFalse);
    });

    test('converts notification toMap correctly', () {
      const notification = GatewayNotification(
        id: 'notif_03',
        type: 'sensor-triggered',
        gatewayId: '08:A6:F7:9E:B3:70',
        sensorId: 'sensor_123',
        createdAt: 1778320000000,
        sentAt: 1778320001000,
      );

      final map = notification.toMap();

      expect(map['type'], equals('sensor-triggered'));
      expect(map['gatewayId'], equals('08:A6:F7:9E:B3:70'));
      expect(map['sensorId'], equals('sensor_123'));
      expect(map['createdAt'], equals(1778320000000));
      expect(map['sentAt'], equals(1778320001000));
    });

    test('maps unknown type to human readable label', () {
      const notification = GatewayNotification(
        id: 'notif_04',
        type: 'custom-event-fired',
        gatewayId: '08:A6:F7:9E:B3:70',
        createdAt: 1778320000000,
      );

      expect(notification.typeLabel, equals('custom event fired'));
    });
  });
}
