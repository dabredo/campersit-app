enum SensorType {
  camera(1, 'Camera'),
  motion(2, 'Motion'),
  air(3, 'Air'),
  led(4, 'LED'),
  buzzer(5, 'Buzzer'),
  unknown(0, 'Unknown');

  final int code;
  final String label;

  const SensorType(this.code, this.label);

  static SensorType fromValue(dynamic rawValue) {
    if (rawValue == null) return SensorType.unknown;
    if (rawValue is int) {
      return switch (rawValue) {
        1 => SensorType.camera,
        2 => SensorType.motion,
        3 => SensorType.air,
        4 => SensorType.led,
        5 => SensorType.buzzer,
        _ => SensorType.unknown,
      };
    }
    final normalized = rawValue.toString().trim().toLowerCase();
    return switch (normalized) {
      '1' || 'camera' => SensorType.camera,
      '2' || 'motion' => SensorType.motion,
      '3' || 'air' => SensorType.air,
      '4' || 'led' => SensorType.led,
      '5' || 'buzzer' => SensorType.buzzer,
      _ => SensorType.unknown,
    };
  }
}

enum SensorState {
  unpaired('u', 'Unpaired'),
  disabled('d', 'Disabled'),
  paired('p', 'Paired'),
  enabled('e', 'Enabled'),
  triggered('t', 'Triggered'),
  started('s', 'Started'),
  deleted('x', 'Deleted'),
  unknown('', 'Unknown');

  final String code;
  final String label;

  const SensorState(this.code, this.label);

  static SensorState fromCode(dynamic rawCode) {
    if (rawCode == null) return SensorState.unknown;
    final normalized = rawCode.toString().trim().toLowerCase();
    return switch (normalized) {
      'u' || 'unpaired' => SensorState.unpaired,
      'd' || 'disabled' => SensorState.disabled,
      'p' || 'paired' => SensorState.paired,
      'e' || 'enabled' => SensorState.enabled,
      't' || 'triggered' => SensorState.triggered,
      's' || 'started' => SensorState.started,
      'x' || 'deleted' => SensorState.deleted,
      _ => SensorState.unknown,
    };
  }
}

class Sensor {
  final String id;
  final SensorType type;
  final SensorState state;
  final String? tag;
  final num? battery;
  final int? seenAt;

  const Sensor({
    required this.id,
    required this.type,
    this.state = SensorState.unknown,
    this.tag,
    this.battery,
    this.seenAt,
  });

  factory Sensor.fromMap(Map<String, dynamic> map, {String? fallbackId}) {
    int? parsedSeenAt;
    final rawSeenAt = map['seenAt'];
    if (rawSeenAt is int) {
      parsedSeenAt = rawSeenAt;
    }

    final rawBattery = map['battery'];
    num? parsedBattery;
    if (rawBattery is num) {
      parsedBattery = rawBattery;
    }

    final resolvedId = fallbackId ?? '';

    return Sensor(
      id: resolvedId,
      type: SensorType.fromValue(map['type']),
      state: SensorState.fromCode(map['state']),
      tag: map['tag']?.toString(),

      battery: parsedBattery,
      seenAt: parsedSeenAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.code,
      'state': state.code,
      if (tag != null) 'tag': tag,
      if (battery != null) 'battery': battery,
      if (seenAt != null) 'seenAt': seenAt,
    };
  }
}
