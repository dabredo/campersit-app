import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/screens/home_screen.dart';
import 'package:campersit_app/screens/notifications_screen.dart';

void main() {
  Widget buildTestWidget({
    required List overrides,
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('renders notification button with badge count and navigates', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userGatewaysProvider.overrideWith(
              (ref) => Stream.value(<Gateway>[]),
            ),
            userNotificationsCountProvider.overrideWithValue(3),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final notifButton = find.byTooltip('Notifications');
      expect(notifButton, findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(notifButton);
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });
  });
}
