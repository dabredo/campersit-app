import 'package:campersit_app/widgets/common/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SurfaceCard', () {
    testWidgets('renders child and applies default padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurfaceCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(SurfaceCard), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SurfaceCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('applies custom padding when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurfaceCard(
              padding: EdgeInsets.all(8),
              child: Text('Custom Padding Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SurfaceCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, equals(const EdgeInsets.all(8)));
    });
  });
}
