import 'package:flutter/material.dart';

import '../models/sensor.dart';

IconData resolveSensorIcon(SensorType type) => switch (type) {
  SensorType.camera => Icons.videocam_rounded,
  SensorType.motion => Icons.motion_photos_on_rounded,
  SensorType.air => Icons.air_rounded,
  SensorType.led => Icons.lightbulb_rounded,
  SensorType.buzzer => Icons.volume_up_rounded,
  SensorType.unknown => Icons.sensors_rounded,
};
