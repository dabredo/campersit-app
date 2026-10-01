import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/providers/notification_provider.dart';
import 'package:campersit_app/widgets/app_notification_bar.dart';
import 'package:campersit_app/widgets/app_notification_listener.dart';

void main() {
  Widget buildTestWidget({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: AppNotificationListener(
            child: Center(
              child: Text('App Main Content'),
            ),
          ),
        ),
      ),
    );
  }

  group('AppNotificationListener Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('renders child and no notification bar initially', (tester) async {
      await tester.pumpWidget(buildTestWidget(container: container));

      expect(find.text('App Main Content'), findsOneWidget);
      expect(find.byType(AppNotificationBar), findsNothing);
    });

    testWidgets('displays notification bar when provider state changes', (tester) async {
      await tester.pumpWidget(buildTestWidget(container: container));

      container.read(notificationProvider.notifier).showSuccess('Operation complete');
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationBar), findsOneWidget);
      expect(find.text('Operation complete'), findsOneWidget);
    });

    testWidgets('dismisses notification bar on close button tap', (tester) async {
      await tester.pumpWidget(buildTestWidget(container: container));

      container.read(notificationProvider.notifier).showInfo('Dismissable alert');
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationBar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationBar), findsNothing);
      expect(container.read(notificationProvider), isNull);
    });

    testWidgets('auto-dismisses notification after duration expires', (tester) async {
      await tester.pumpWidget(buildTestWidget(container: container));

      const notificationDuration = Duration(seconds: 2);
      container.read(notificationProvider.notifier).showWarning(
            'Timed warning',
            duration: notificationDuration,
          );
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationBar), findsOneWidget);

      await tester.pump(notificationDuration);
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationBar), findsNothing);
      expect(container.read(notificationProvider), isNull);
    });
  });
}
