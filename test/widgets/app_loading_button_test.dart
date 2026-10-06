import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/widgets/app_loading_button.dart';

void main() {
  group('AppLoadingButton', () {
    testWidgets('renders label and handles tap when not loading', (tester) async {
      var isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingButton(
              isLoading: false,
              onPressed: () => isTapped = true,
              label: 'Submit',
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AppLoadingButton));
      await tester.pump();

      expect(isTapped, isTrue);
    });

    testWidgets('shows loading spinner and disables interaction when loading', (tester) async {
      var isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingButton(
              isLoading: true,
              onPressed: () => isTapped = true,
              label: 'Submit',
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(AppLoadingButton));
      await tester.pump();

      expect(isTapped, isFalse);
    });
  });
}
