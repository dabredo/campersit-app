import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/capture_providers.dart';
import 'package:campersit_app/screens/camera_captures_screen.dart';
import 'package:campersit_app/widgets/sensor/sensor_card/camera_recordings_button.dart';

void main() {
  testWidgets('CameraRecordingsButton navigates to CameraCapturesScreen on tap', (
    tester,
  ) async {
    const sensor = Sensor(
      id: 'CAM-1',
      type: SensorType.camera,
      state: SensorState.enabled,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraCapturesProvider(
            (gatewayId: 'GW-1', sensorId: 'CAM-1'),
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CameraRecordingsButton(gatewayId: 'GW-1', sensor: sensor),
          ),
        ),
      ),
    );

    expect(find.text('Recordings'), findsOneWidget);
    await tester.tap(find.text('Recordings'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraCapturesScreen), findsOneWidget);
  });
}
