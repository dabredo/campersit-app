import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/models/gateway_notification.dart';
import 'package:campersit_app/models/notification_preference.dart';
import 'package:campersit_app/models/user_device_token.dart';
import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/providers/notification_settings_providers.dart';
import 'package:campersit_app/screens/home_screen.dart';
import 'package:campersit_app/screens/main_navigation_shell.dart';
import 'package:campersit_app/screens/notification_settings_screen.dart';
import 'package:campersit_app/screens/notifications_screen.dart';
import 'package:campersit_app/widgets/navigation/campersit_bottom_nav_bar.dart';

void main() {
  group('MainNavigationShell Widget Tests', () {
    testWidgets('renders shell with tabs and switches between screens', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userGatewaysProvider.overrideWith((ref) => Stream.value(<Gateway>[])),
            userNotificationsProvider.overrideWith(
              (ref) => Stream.value(<GatewayNotification>[]),
            ),
            userNotificationsCountProvider.overrideWithValue(2),
            userDeviceTokensProvider.overrideWith(
              (ref) => Stream.value(<UserDeviceToken>[]),
            ),
            userNotificationPreferencesProvider.overrideWith(
              (ref) => Stream.value(<String, NotificationPreference>{}),
            ),
          ],
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CampersitBottomNavBar), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('No Gateways'), findsOneWidget);

      await tester.tap(find.text('Notificaciones'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);

      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
      expect(find.text('Delivery Preferences'), findsOneWidget);
    });
  });
}
