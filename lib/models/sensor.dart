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

  static SensorType fromValue(Object? rawValue) {
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

  bool get isActuator =>
      this == SensorType.camera ||
      this == SensorType.led ||
      this == SensorType.buzzer;
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

  static SensorState fromCode(Object? rawCode) {
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
  final Map<String, Object?> alerts;
  final Map<String, Object?> values;
  final List<String> actions;

  const Sensor({
    required this.id,
    required this.type,
    this.state = SensorState.unknown,
    this.tag,
    this.battery,
    this.seenAt,
    this.alerts = const {},
    this.values = const {},
    this.actions = const [],
  });

  factory Sensor.fromMap(String id, Map<String, Object?> map) {
    return Sensor(
      id: id,
      type: SensorType.fromValue(map['type']),
      state: SensorState.fromCode(map['state'] as String?),
      tag: map['tag'] as String?,
      battery: map['battery'] as num?,
      seenAt: map['seenAt'] as int?,
      alerts: (map['alerts'] as Map?)?.cast<String, Object?>() ?? const {},
      values: (map['values'] as Map?)?.cast<String, Object?>() ?? const {},
      actions: (map['actions'] as List?)?.cast<String>() ?? const [],
    );
  }

  // Hardware sensors lack decimal precision; values are represented as integers.
  int? get temperature => (values['temperature'] as num?)?.round();
  int? get humidity => (values['humidity'] as num?)?.round();

  bool get isActuator => type.isActuator;

  List<SensorState> get availableTransitions => switch (state) {
        SensorState.paired => [
          SensorState.enabled,
          if (isActuator) SensorState.started,
        ],
        SensorState.triggered => [
          SensorState.enabled,
          SensorState.paired,
        ],
        SensorState.enabled => [
          SensorState.paired,
        ],
        SensorState.started when isActuator => [
          SensorState.enabled,
          SensorState.paired,
        ],
        _ => const [],
      };

  Map<String, Object?> toMap() {
    return {
      'type': type.code,
      'state': state.code,
      if (tag != null) 'tag': tag,
      if (battery != null) 'battery': battery,
      if (seenAt != null) 'seenAt': seenAt,
      if (alerts.isNotEmpty) 'alerts': alerts,
      if (values.isNotEmpty) 'values': values,
      if (actions.isNotEmpty) 'actions': actions,
    };
  }
}
