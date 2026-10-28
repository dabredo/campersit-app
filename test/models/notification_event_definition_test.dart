import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/notification_event_definition.dart';
import 'package:campersit_app/theme/app_theme.dart';

void main() {
  group('NotificationEventDefinition Tests', () {
    test('allEvents contains all standard catalog events', () {
      final types =
          NotificationEventDefinition.allEvents.map((e) => e.type).toList();

      expect(types, contains('device-initializing'));
      expect(types, contains('device-missing'));
      expect(types, contains('device-not-missing'));
      expect(types, contains('device-power-loss'));
      expect(types, contains('device-power-restored'));
      expect(types, contains('sensor-missing'));
      expect(types, contains('sensor-not-missing'));
      expect(types, contains('sensor-started'));
      expect(types, contains('sensor-started-off'));
      expect(types, contains('sensor-triggered'));
      expect(types, contains('sensor-triggered-off'));
      expect(types, contains('sensor-battery-critical'));
      expect(types, contains('sensor-battery-low'));
      expect(types, contains('sensor-battery-good'));
      expect(types.length, equals(14));
    });

    test('forType returns correct definition for known type', () {
      final def = NotificationEventDefinition.forType('device-missing');

      expect(def.type, equals('device-missing'));
      expect(def.title, equals('Gateway Offline'));
      expect(def.icon, equals(Icons.cloud_off_rounded));
      expect(def.color, equals(AppColors.danger));
    });

    test('forType returns fallback definition for unknown type', () {
      final def = NotificationEventDefinition.forType('custom-device-alert');

      expect(def.type, equals('custom-device-alert'));
      expect(def.title, equals('custom device alert'));
      expect(def.icon, equals(Icons.notifications_rounded));
      expect(def.color, equals(AppColors.textSecondary));
    });
  });
}
