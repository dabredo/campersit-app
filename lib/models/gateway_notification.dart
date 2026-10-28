class GatewayNotification {
  final String id;
  final String type;
  final String gatewayId;
  final String? sensorId;
  final int createdAt;
  final int? sentAt;

  const GatewayNotification({
    required this.id,
    required this.type,
    required this.gatewayId,
    this.sensorId,
    required this.createdAt,
    this.sentAt,
  });

  bool get isSensorRelated => sensorId != null && sensorId!.isNotEmpty;

  String get typeLabel => switch (type) {
    'device-initializing' => 'Gateway Initializing',
    'device-missing' => 'Gateway Offline',
    'device-not-missing' => 'Gateway Online',
    'device-power-loss' => 'Gateway Power Loss',
    'device-power-restored' => 'Gateway Power Restored',
    'sensor-missing' => 'Sensor Offline',
    'sensor-not-missing' => 'Sensor Online',
    'sensor-started' => 'Actuator Started',
    'sensor-started-off' => 'Actuator Stopped',
    'sensor-triggered' => 'Sensor Triggered',
    'sensor-triggered-off' => 'Sensor Trigger Cleared',
    'sensor-battery-critical' => 'Sensor Battery Critical',
    'sensor-battery-low' => 'Sensor Battery Low',
    'sensor-battery-good' => 'Sensor Battery Normal',
    _ => type.replaceAll('-', ' ').trim(),
  };

  factory GatewayNotification.fromMap(String id, Map<String, Object?> map) {
    return GatewayNotification(
      id: id,
      type: map['type'] as String,
      gatewayId: map['gatewayId'] as String,
      sensorId: map['sensorId'] as String?,
      createdAt: map['createdAt'] as int,
      sentAt: map['sentAt'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'type': type,
      'gatewayId': gatewayId,
      if (sensorId != null) 'sensorId': sensorId,
      'createdAt': createdAt,
      if (sentAt != null) 'sentAt': sentAt,
    };
  }
}
