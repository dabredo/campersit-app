import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/navigation/campersit_bottom_nav_bar.dart';

void main() {
  group('CampersitBottomNavBar Widget Tests', () {
    testWidgets('renders 3 tabs with labels and triggers onTap', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CampersitBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              unreadNotificationsCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('Notificaciones'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Ajustes'));
      expect(tappedIndex, 2);

      await tester.tap(find.text('Home'));
      expect(tappedIndex, 0);
    });
  });
}
