import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfirmDialog', () {
    testWidgets('renders title, content and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppConfirmDialog(
              title: 'Confirm Delete',
              content: 'Are you sure you want to proceed?',
            ),
          ),
        ),
      );

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('returns true when confirm button is pressed via show()', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await AppConfirmDialog.show(
                      context,
                      title: 'Delete Item',
                      content: 'Confirm deletion?',
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Delete Item'), findsNothing);
    });

    testWidgets('returns false when cancel button is pressed via show()', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await AppConfirmDialog.show(
                      context,
                      title: 'Delete Item',
                      content: 'Confirm deletion?',
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.text('Delete Item'), findsNothing);
    });

    testWidgets('supports custom labels and non-destructive styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppConfirmDialog(
              title: 'Save Changes',
              content: 'Do you want to save?',
              confirmLabel: 'Save',
              cancelLabel: 'Discard',
              isDestructive: false,
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save'),
      );
      expect(
        confirmButton.style?.backgroundColor?.resolve({}),
        AppColors.primaryAccent,
      );
    });
  });
}
