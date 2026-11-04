import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/user_device_token.dart';
import 'package:campersit_app/widgets/notifications/device_token_card.dart';

void main() {
  group('DeviceTokenCard', () {
    testWidgets('renders truncated token, device label, and confirms deletion', (
      tester,
    ) async {
      var deleted = false;
      const token = UserDeviceToken(
        id: 'token-1',
        fcmToken: '1234567890abcdef1234567890abcdef',
        userAgent: 'Android',
        lastUpdated: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceTokenCard(
              token: token,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('12345678...90abcdef'), findsOneWidget);
      expect(find.text('Active recently'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Delete device token'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Device Token?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });
  });
}
