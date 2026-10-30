import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/gateway.dart';
import 'package:campersit_app/providers/gateway_providers.dart';
import 'package:campersit_app/screens/home_screen.dart';

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
    testWidgets('renders AppBar with title and logo, and empty state when no gateways', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            userGatewaysProvider.overrideWith(
              (ref) => Stream.value(<Gateway>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gateways'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
      expect(find.byIcon(Icons.logout_rounded), findsNothing);
      expect(find.byTooltip('Sign out'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('No Gateways'), findsOneWidget);
    });
  });
}
