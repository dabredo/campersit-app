import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/utils/sensor_icon_resolver.dart';

void main() {
  group('resolveSensorIcon Tests', () {
    test('resolves correct icons for all sensor types', () {
      expect(resolveSensorIcon(SensorType.camera), equals(Icons.videocam_rounded));
      expect(resolveSensorIcon(SensorType.motion), equals(Icons.motion_photos_on_rounded));
      expect(resolveSensorIcon(SensorType.air), equals(Icons.air_rounded));
      expect(resolveSensorIcon(SensorType.led), equals(Icons.lightbulb_rounded));
      expect(resolveSensorIcon(SensorType.buzzer), equals(Icons.volume_up_rounded));
      expect(resolveSensorIcon(SensorType.unknown), equals(Icons.sensors_rounded));
    });
  });
}
