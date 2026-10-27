import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway_notification.dart';
import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/screens/gateway_detail_screen.dart';
import 'package:campersit_app/screens/notifications_screen.dart';
import 'package:campersit_app/widgets/notifications/notification_item_card.dart';

void main() {
  Widget buildTestWidget({
    required List overrides,
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
  }

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders loading indicator when stream is loading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userNotificationsProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error view when stream emits error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userNotificationsProvider.overrideWith(
              (ref) => Stream.error(Exception('Failed to load')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load notifications'), findsOneWidget);
    });

    testWidgets('renders empty state when notifications list is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userNotificationsProvider.overrideWith(
              (ref) => Stream.value(<GatewayNotification>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Notifications'), findsOneWidget);
      expect(
        find.text(
          'When events occur on your gateways or sensors, they will appear here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders list of notifications with cards and details', (tester) async {
      const notif1 = GatewayNotification(
        id: 'n1',
        type: 'sensor-triggered',
        gatewayId: '08:A6:F7:9E:B3:70',
        sensorId: 'EC:E3:34:15:F3:8C',
        createdAt: 1778320000000,
      );
      const notif2 = GatewayNotification(
        id: 'n2',
        type: 'device-initializing',
        gatewayId: '08:A6:F7:9E:B3:70',
        createdAt: 1778310000000,
      );

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userNotificationsProvider.overrideWith(
              (ref) => Stream.value([notif1, notif2]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationItemCard), findsNWidgets(2));
      expect(find.text('Sensor Triggered'), findsOneWidget);
      expect(find.text('Gateway Initializing'), findsOneWidget);
      expect(find.text('GW: 08:A6:F7:9E:B3:70'), findsNWidgets(2));
      expect(find.text('SENSOR: EC:E3:34:15:F3:8C'), findsOneWidget);
    });

    testWidgets('navigates to GatewayDetailScreen when card is tapped', (tester) async {
      const notif1 = GatewayNotification(
        id: 'n1',
        type: 'sensor-triggered',
        gatewayId: '08:A6:F7:9E:B3:70',
        createdAt: 1778320000000,
      );

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userNotificationsProvider.overrideWith(
              (ref) => Stream.value([notif1]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationItemCard));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GatewayDetailScreen), findsOneWidget);
    });
  });
}
