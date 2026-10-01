import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../utils/error_formatter.dart';

class NotificationNotifier extends Notifier<AppNotification?> {
  @override
  AppNotification? build() => null;

  void showError(Object error, {Duration duration = const Duration(seconds: 4)}) {
    state = _createNotification(
      message: AppErrorFormatter.format(error),
      type: NotificationType.error,
      duration: duration,
    );
  }

  void showSuccess(String message, {Duration duration = const Duration(seconds: 4)}) {
    state = _createNotification(
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }

  void showWarning(String message, {Duration duration = const Duration(seconds: 4)}) {
    state = _createNotification(
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }

  void showInfo(String message, {Duration duration = const Duration(seconds: 4)}) {
    state = _createNotification(
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }

  void dismiss() {
    state = null;
  }

  AppNotification _createNotification({
    required String message,
    required NotificationType type,
    required Duration duration,
  }) {
    return AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      type: type,
      duration: duration,
    );
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, AppNotification?>(
  NotificationNotifier.new,
);
