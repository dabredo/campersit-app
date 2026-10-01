enum NotificationType {
  success,
  error,
  warning,
  info,
}

class AppNotification {
  final String id;
  final String message;
  final NotificationType type;
  final Duration duration;

  AppNotification({
    required this.id,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 4),
  });
}
