import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/widgets/common/bottom_nav_bar.dart';
import 'package:campersit_app/widgets/common/custom_scaffold.dart';
import 'package:campersit_app/widgets/common/nav_bar.dart';

void main() {
  group('CustomScaffold Widget Tests', () {
    testWidgets('renders title, body, and bottom bar by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userNotificationsCountProvider.overrideWithValue(0),
          ],
          child: const MaterialApp(
            home: CustomScaffold(
              title: 'Test Page',
              body: Text('Page Content'),
            ),
          ),
        ),
      );

      expect(find.text('TEST PAGE'), findsOneWidget);
      expect(find.text('Page Content'), findsOneWidget);
      expect(find.byType(NavBar), findsOneWidget);
      expect(find.byType(BottomNavBar), findsOneWidget);
    });

    testWidgets('omits bottom bar when showBottomNavBar is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomScaffold(
            title: 'No Bottom Bar',
            showBottomNavBar: false,
            body: Text('Content'),
          ),
        ),
      );

      expect(find.text('NO BOTTOM BAR'), findsOneWidget);
      expect(find.byType(BottomNavBar), findsNothing);
    });

    testWidgets('supports custom appBar and floatingActionButton', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userNotificationsCountProvider.overrideWithValue(0),
          ],
          child: const MaterialApp(
            home: CustomScaffold(
              showBottomNavBar: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Text('Custom Bar'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.add),
              ),
              body: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Bar'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(NavBar), findsNothing);
    });
  });
}
