import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/notification_preference.dart';

void main() {
  group('NotificationDeliveryChannel Tests', () {
    test('resolves fromBooleans correctly', () {
      expect(
        NotificationDeliveryChannel.fromBooleans(app: false, email: false),
        equals(NotificationDeliveryChannel.none),
      );
      expect(
        NotificationDeliveryChannel.fromBooleans(app: true, email: false),
        equals(NotificationDeliveryChannel.app),
      );
      expect(
        NotificationDeliveryChannel.fromBooleans(app: false, email: true),
        equals(NotificationDeliveryChannel.email),
      );
      expect(
        NotificationDeliveryChannel.fromBooleans(app: true, email: true),
        equals(NotificationDeliveryChannel.both),
      );
    });

    test('flags includesApp and includesEmail reflect channel value', () {
      expect(NotificationDeliveryChannel.none.includesApp, isFalse);
      expect(NotificationDeliveryChannel.none.includesEmail, isFalse);

      expect(NotificationDeliveryChannel.app.includesApp, isTrue);
      expect(NotificationDeliveryChannel.app.includesEmail, isFalse);

      expect(NotificationDeliveryChannel.email.includesApp, isFalse);
      expect(NotificationDeliveryChannel.email.includesEmail, isTrue);

      expect(NotificationDeliveryChannel.both.includesApp, isTrue);
      expect(NotificationDeliveryChannel.both.includesEmail, isTrue);
    });
  });

  group('NotificationPreference Model Tests', () {
    test('parses NotificationPreference fromMap with true values', () {
      final map = <String, Object?>{
        'app': true,
        'email': false,
      };

      final pref = NotificationPreference.fromMap('sensor-triggered', map);

      expect(pref.eventType, equals('sensor-triggered'));
      expect(pref.app, isTrue);
      expect(pref.email, isFalse);
      expect(pref.channel, equals(NotificationDeliveryChannel.app));
    });

    test('parses NotificationPreference fromMap with both enabled', () {
      final map = <String, Object?>{
        'app': true,
        'email': true,
      };

      final pref = NotificationPreference.fromMap('device-missing', map);

      expect(pref.eventType, equals('device-missing'));
      expect(pref.channel, equals(NotificationDeliveryChannel.both));
    });

    test('parses NotificationPreference fromMap with missing keys as false', () {
      final map = <String, Object?>{
        'email': true,
      };

      final pref = NotificationPreference.fromMap('device-power-loss', map);

      expect(pref.app, isFalse);
      expect(pref.email, isTrue);
      expect(pref.channel, equals(NotificationDeliveryChannel.email));
    });

    test('converts NotificationPreference toMap', () {
      const pref = NotificationPreference(
        eventType: 'sensor-battery-low',
        app: true,
        email: true,
      );

      final map = pref.toMap();

      expect(map['app'], isTrue);
      expect(map['email'], isTrue);
    });
  });

  group('NotificationEventDefinition Tests', () {
    test('allEvents contains all standard catalog events', () {
      final types = NotificationEventDefinition.allEvents.map((e) => e.type).toList();

      expect(types, contains('device-missing'));
      expect(types, contains('device-not-missing'));
      expect(types, contains('device-power-loss'));
      expect(types, contains('device-power-restored'));
      expect(types, contains('device-initializing'));
      expect(types, contains('sensor-triggered'));
      expect(types, contains('sensor-battery-low'));
      expect(types, contains('sensor-missing'));
      expect(types, contains('sensor-not-missing'));
      expect(types.length, equals(9));
    });
  });
}
