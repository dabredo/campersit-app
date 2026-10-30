import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/notification_preference.dart';
import 'package:campersit_app/models/user_device_token.dart';
import 'package:campersit_app/providers/auth_providers.dart';
import 'package:campersit_app/providers/notification_settings_providers.dart';
import 'package:campersit_app/screens/notification_settings_screen.dart';
import 'package:campersit_app/services/auth_service.dart';
import 'package:campersit_app/widgets/notifications/device_token_card.dart';
import 'package:campersit_app/widgets/notifications/notification_channel_card.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  Widget buildTestWidget({
    required List overrides,
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: const MaterialApp(
        home: NotificationSettingsScreen(),
      ),
    );
  }

  group('NotificationSettingsScreen Widget Tests', () {
    testWidgets('renders sections, titles, and event channel cards', (tester) async {
      tester.view.physicalSize = const Size(800, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userDeviceTokensProvider.overrideWith(
              (ref) => Stream.value(<UserDeviceToken>[]),
            ),
            userNotificationPreferencesProvider.overrideWith(
              (ref) => Stream.value(<String, NotificationPreference>{
                'sensor-triggered': const NotificationPreference(
                  eventType: 'sensor-triggered',
                  app: true,
                  email: false,
                ),
              }),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Delivery Preferences'), findsOneWidget);
      expect(find.text('Registered Device Tokens'), findsOneWidget);
      expect(find.byType(NotificationChannelCard), findsWidgets);
      expect(find.text('Sensor Triggered'), findsOneWidget);
      expect(find.text('Gateway Offline'), findsOneWidget);
      expect(find.text('App'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.byType(Switch), findsWidgets);
      expect(find.text('No Device Tokens Registered'), findsOneWidget);
    });

    testWidgets('renders registered device token and opens delete dialog on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const sampleToken = UserDeviceToken(
        id: 'token_1',
        fcmToken: 'fcm_long_token_string_1234567890',
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
        lastUpdated: 1718000000000,
      );

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userDeviceTokensProvider.overrideWith(
              (ref) => Stream.value([sampleToken]),
            ),
            userNotificationPreferencesProvider.overrideWith(
              (ref) => Stream.value(<String, NotificationPreference>{}),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeviceTokenCard), findsOneWidget);
      expect(find.text('macOS Device'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Delete Device Token?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders error states when preferences or tokens stream emits error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userDeviceTokensProvider.overrideWith(
              (ref) => Stream.error(Exception('Token error')),
            ),
            userNotificationPreferencesProvider.overrideWith(
              (ref) => Stream.error(Exception('Pref error')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load preferences'), findsOneWidget);
      expect(find.text('Failed to load device tokens'), findsOneWidget);
    });

    testWidgets('renders logout button and triggers sign out on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockAuth = _MockAuthService();
      when(() => mockAuth.terminateSession()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userDeviceTokensProvider.overrideWith(
              (ref) => Stream.value(<UserDeviceToken>[]),
            ),
            userNotificationPreferencesProvider.overrideWith(
              (ref) => Stream.value(<String, NotificationPreference>{}),
            ),
            authServiceProvider.overrideWithValue(mockAuth),
            currentUserEmailProvider.overrideWithValue('user@campersit.com'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.textContaining('user@campersit.com'), findsOneWidget);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuth.terminateSession()).called(1);
    });
  });
}

class _MockAuthService extends Mock implements AuthService {}

