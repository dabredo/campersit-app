import 'notification_event_definition.dart';

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

  NotificationEventDefinition get definition =>
      NotificationEventDefinition.forType(type);

  String get typeLabel => definition.title;

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
