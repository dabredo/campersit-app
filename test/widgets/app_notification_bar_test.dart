import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/app_notification.dart';
import 'package:campersit_app/widgets/app_notification_bar.dart';

void main() {
  Widget buildTestWidget({
    required AppNotification notification,
    required VoidCallback onDismiss,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppNotificationBar(
          notification: notification,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  group('AppNotificationBar Widget Tests', () {
    testWidgets('renders success notification with message and icon', (tester) async {
      final notification = AppNotification(
        id: 'test-1',
        message: 'Saved successfully',
        type: NotificationType.success,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () {},
        ),
      );

      expect(find.text('Saved successfully'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders error notification icon and message', (tester) async {
      final notification = AppNotification(
        id: 'test-2',
        message: 'Connection failed',
        type: NotificationType.error,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () {},
        ),
      );

      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('renders warning notification icon and message', (tester) async {
      final notification = AppNotification(
        id: 'test-3',
        message: 'Low memory warning',
        type: NotificationType.warning,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () {},
        ),
      );

      expect(find.text('Low memory warning'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('renders info notification icon and message', (tester) async {
      final notification = AppNotification(
        id: 'test-4',
        message: 'New update available',
        type: NotificationType.info,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () {},
        ),
      );

      expect(find.text('New update available'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('triggers onDismiss callback when close button is tapped', (tester) async {
      var isDismissed = false;
      final notification = AppNotification(
        id: 'test-5',
        message: 'Tap to dismiss',
        type: NotificationType.info,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () => isDismissed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(isDismissed, isTrue);
    });

    testWidgets('triggers onDismiss callback when dismissed with upward drag', (tester) async {
      var isDismissed = false;
      final notification = AppNotification(
        id: 'test-6',
        message: 'Swipe to dismiss',
        type: NotificationType.info,
      );

      await tester.pumpWidget(
        buildTestWidget(
          notification: notification,
          onDismiss: () => isDismissed = true,
        ),
      );

      await tester.drag(find.byType(Dismissible), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(isDismissed, isTrue);
    });
  });
}
