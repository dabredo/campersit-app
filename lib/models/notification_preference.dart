export 'notification_event_definition.dart';

class NotificationPreference {
  final String eventType;
  final bool app;
  final bool email;

  const NotificationPreference({
    required this.eventType,
    required this.app,
    required this.email,
  });

  factory NotificationPreference.fromMap(
    String eventType,
    Map<String, Object?> map,
  ) {
    return NotificationPreference(
      eventType: eventType,
      app: (map['app'] as bool?) ?? false,
      email: (map['email'] as bool?) ?? false,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'app': app,
      'email': email,
    };
  }
}
