import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/widgets/sensor/sensor_card/sensor_dialogs.dart';

void main() {
  group('sensor_dialogs', () {
    testWidgets('EditSensorTagButton triggers onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditSensorTagButton(
              sensorId: 'S-1',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('edit_sensor_tag_S-1')));
      expect(tapped, isTrue);
    });

    testWidgets('EditSensorTagDialog saves trimmed tag and closes on success', (
      tester,
    ) async {
      String? savedTag;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => EditSensorTagDialog(
                      initialTag: 'Old Tag',
                      sensorId: 'S-1',
                      onSave: (newTag) async {
                        savedTag = newTag;
                        return true;
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Sensor Tag'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  Kitchen  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedTag, equals('Kitchen'));
      expect(find.text('Edit Sensor Tag'), findsNothing);
    });
  });
}

