import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/nav_bar.dart';

void main() {
  group('NavBar Widget Tests', () {
    testWidgets('renders centered title and logo without back button by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: NavBar(title: 'Gateways'),
          ),
        ),
      );

      expect(find.text('GATEWAYS'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.height, equals(44));
      expect(image.width, equals(44));
    });

    testWidgets('renders back button when showBackButton is true and triggers callback', (tester) async {
      var backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: NavBar(
              title: 'Gateway Details',
              showBackButton: true,
              onBackPressed: () => backPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('GATEWAY DETAILS'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backPressed, isTrue);
    });
  });
}
