import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/common/app_delete_button.dart';

void main() {
  group('AppDeleteButton', () {
    testWidgets('renders delete icon and triggers onTap when pressed', (
      tester,
    ) async {
      var isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDeleteButton(
              buttonKey: const ValueKey('delete_test_btn'),
              onTap: () => isTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.byKey(const ValueKey('delete_test_btn')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('delete_test_btn')));
      expect(isTapped, isTrue);
    });

    testWidgets('renders loading spinner and hides action button when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDeleteButton(
              buttonKey: const ValueKey('delete_test_btn'),
              isLoading: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(find.byKey(const ValueKey('delete_test_btn')), findsNothing);
    });

    testWidgets('renders tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDeleteButton(
              tooltip: 'Delete item',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byTooltip('Delete item'), findsOneWidget);
    });
  });
}
