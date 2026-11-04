import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/notification_event_definition.dart';
import 'package:campersit_app/widgets/notifications/notification_channel_card.dart';

void main() {
  group('NotificationChannelCard', () {
    testWidgets('renders event info and triggers channel callbacks', (
      tester,
    ) async {
      bool? appValue;
      bool? emailValue;
      final event = NotificationEventDefinition.forType('gateway-missing');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationChannelCard(
              event: event,
              appEnabled: true,
              emailEnabled: false,
              onAppChanged: (value) => appValue = value,
              onEmailChanged: (value) => emailValue = value,
            ),
          ),
        ),
      );

      expect(find.text(event.title), findsOneWidget);
      expect(find.text(event.description), findsOneWidget);

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      await tester.tap(switches.first);
      await tester.pump();
      expect(appValue, isFalse);

      await tester.tap(switches.last);
      await tester.pump();
      expect(emailValue, isTrue);
    });
  });
}

