import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/widgets/common/add_device_bottom_sheet.dart';

void main() {
  Widget buildTestableWidget({
    bool isLoading = false,
    Future<bool> Function(String id)? onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AddDeviceBottomSheet(
          title: 'Add Test Device',
          description: 'Enter your device ID to continue.',
          idLabel: 'Device ID',
          icon: Icons.developer_board,
          submitLabel: 'Register Device',
          isLoading: isLoading,
          onSubmit: onSubmit ?? ((_) async => true),
        ),
      ),
    );
  }

  group('AddDeviceBottomSheet', () {
    testWidgets('renders all custom texts and form elements', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Add Test Device'), findsOneWidget);
      expect(find.text('Enter your device ID to continue.'), findsOneWidget);
      expect(find.text('Device ID'), findsOneWidget);
      expect(find.text('Register Device'), findsOneWidget);
      expect(find.byIcon(Icons.developer_board), findsOneWidget);
    });

    testWidgets('formats input using MAC address format', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextFormField), 'aabbcc112233');
      await tester.pump();

      expect(find.text('AA:BB:CC:11:22:33'), findsOneWidget);
    });

    testWidgets('validates required and MAC format on submit', (tester) async {
      var submitted = false;
      await tester.pumpWidget(
        buildTestableWidget(
          onSubmit: (id) async {
            submitted = true;
            return true;
          },
        ),
      );

      // Empty submission
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Device'));
      await tester.pump();

      expect(find.text('Please enter your Device ID'), findsOneWidget);
      expect(submitted, isFalse);

      // Incomplete MAC
      await tester.enterText(find.byType(TextFormField), 'AA:BB');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Device'));
      await tester.pump();

      expect(
        find.text('Please enter a valid MAC address (e.g. AA:BB:CC:11:22:33)'),
        findsOneWidget,
      );
      expect(submitted, isFalse);
    });

    testWidgets('calls onSubmit and pops on success', (tester) async {
      String? submittedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AddDeviceBottomSheet.show(
                  context,
                  builder: (context) => AddDeviceBottomSheet(
                    title: 'Add Test Device',
                    description: 'Enter your device ID.',
                    idLabel: 'Device ID',
                    icon: Icons.developer_board,
                    submitLabel: 'Register Device',
                    isLoading: false,
                    onSubmit: (id) async {
                      submittedId = id;
                      return true;
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'AA:BB:CC:11:22:33');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Device'));
      await tester.pumpAndSettle();

      expect(submittedId, equals('AA:BB:CC:11:22:33'));
      expect(find.text('Add Test Device'), findsNothing);
    });
  });
}
