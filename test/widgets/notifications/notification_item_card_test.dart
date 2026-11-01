import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway_notification.dart';
import 'package:campersit_app/widgets/common/app_device_id_text.dart';
import 'package:campersit_app/widgets/notifications/notification_item_card.dart';

void main() {
  group('NotificationItemCard Widget Tests', () {
    testWidgets('renders icon and title from notification definition',
        (tester) async {
      const notification = GatewayNotification(
        id: 'n1',
        type: 'sensor-triggered',
        gatewayId: '08:A6:F7:9E:B3:70',
        sensorId: 'EC:E3:34:15:F3:8C',
        createdAt: 1778320000000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(notification: notification),
          ),
        ),
      );

      expect(find.text('Sensor Triggered'), findsOneWidget);
      expect(find.byIcon(Icons.motion_photos_on_rounded), findsOneWidget);
    });

    testWidgets(
        'renders sensor ID using AppDeviceIdText when sensorId is present',
        (tester) async {
      const notification = GatewayNotification(
        id: 'n1',
        type: 'sensor-triggered',
        gatewayId: '08:A6:F7:9E:B3:70',
        sensorId: 'EC:E3:34:15:F3:8C',
        createdAt: 1778320000000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(notification: notification),
          ),
        ),
      );

      expect(find.byType(AppDeviceIdText), findsOneWidget);
      expect(find.text('EC:E3:34:15:F3:8C'), findsOneWidget);
      expect(find.text('08:A6:F7:9E:B3:70'), findsNothing);
      expect(find.textContaining('GW'), findsNothing);
      expect(find.textContaining('SENSOR'), findsNothing);
    });

    testWidgets(
        'renders gateway ID using AppDeviceIdText when sensorId is absent',
        (tester) async {
      const notification = GatewayNotification(
        id: 'n2',
        type: 'gateway-disconnected',
        gatewayId: '08:A6:F7:9E:B3:70',
        createdAt: 1778320000000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(notification: notification),
          ),
        ),
      );

      expect(find.byType(AppDeviceIdText), findsOneWidget);
      expect(find.text('08:A6:F7:9E:B3:70'), findsOneWidget);
      expect(find.textContaining('GW'), findsNothing);
      expect(find.textContaining('SENSOR'), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      const notification = GatewayNotification(
        id: 'n2',
        type: 'device-power-loss',
        gatewayId: '08:A6:F7:9E:B3:70',
        createdAt: 1778320000000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: notification,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NotificationItemCard));
      expect(tapped, isTrue);
    });
  });
}
