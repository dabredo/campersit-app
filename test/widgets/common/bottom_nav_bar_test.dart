import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/screens/main_navigation_shell.dart';
import 'package:campersit_app/widgets/common/bottom_nav_bar.dart';

void main() {
  group('BottomNavBar Widget Tests', () {
    testWidgets('renders 3 tabs with labels and triggers explicit onTap', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: BottomNavBar(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
                unreadNotificationsCount: 5,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.router_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      await tester.tap(find.text('Notifications'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Account'));
      expect(tappedIndex, 2);

      await tester.tap(find.text('Devices'));
      expect(tappedIndex, 0);
    });

    testWidgets('default onTap updates mainNavigationIndexProvider and marks notifications seen', (tester) async {
      final container = ProviderContainer(
        overrides: [
          userNotificationsCountProvider.overrideWithValue(0),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              bottomNavigationBar: BottomNavBar(),
            ),
          ),
        ),
      );

      expect(container.read(mainNavigationIndexProvider), 0);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(container.read(mainNavigationIndexProvider), 1);
      expect(container.read(lastSeenNotificationTimestampProvider), greaterThan(0));

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(container.read(mainNavigationIndexProvider), 2);
    });
  });
}
