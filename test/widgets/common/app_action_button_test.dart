import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_action_button.dart';

void main() {
  group('AppActionButton Widget Tests', () {
    testWidgets('renders icon and label with custom styling and 38px height', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppActionButton(
              label: 'Test Action',
              icon: Icons.shield_outlined,
              backgroundColor: AppColors.armBackground,
              borderColor: AppColors.armBorder,
              foregroundColor: AppColors.armText,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Action'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      final buttonFinder = find.byType(OutlinedButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<OutlinedButton>(buttonFinder);
      expect(
        button.style?.backgroundColor?.resolve({}),
        equals(AppColors.armBackground),
      );
      expect(
        button.style?.foregroundColor?.resolve({}),
        equals(AppColors.armText),
      );

      final size = tester.getSize(find.byType(AppActionButton));
      expect(size.height, equals(38));
    });

    testWidgets('sizes intrinsically in a Wrap so multiple buttons sit horizontally', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: Wrap(
                children: [
                  AppActionButton(
                    label: 'Enable',
                    icon: Icons.power_settings_new_rounded,
                    onPressed: () {},
                  ),
                  AppActionButton(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final enableTopLeft = tester.getTopLeft(find.text('Enable'));
      final startTopLeft = tester.getTopLeft(find.text('Start'));

      // Both buttons must be on the same horizontal row (same dy)
      expect(enableTopLeft.dy, equals(startTopLeft.dy));
      // Start button must be to the right of Enable
      expect(startTopLeft.dx, greaterThan(enableTopLeft.dx));
    });

    testWidgets('triggers onPressed when tapped in normal state', (
      tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppActionButton(
              label: 'Click Me',
              icon: Icons.play_arrow_rounded,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('renders loading spinner and ignores tap when isLoading is true', (
      tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppActionButton(
              label: 'Loading Action',
              icon: Icons.refresh_rounded,
              isLoading: true,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Action'), findsNothing);

      await tester.tap(find.byType(AppActionButton));
      await tester.pump();

      expect(wasTapped, isFalse);
    });

    testWidgets('ignores tap when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppActionButton(
              label: 'Disabled Action',
              icon: Icons.lock_rounded,
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(button.onPressed, isNull);
    });
  });
}
