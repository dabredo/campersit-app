import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../theme/app_theme.dart';

class AppNotificationBar extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const AppNotificationBar({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final style = _NotificationStyle.fromType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: style.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                style.icon,
                color: style.foregroundColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.message,
                  style: TextStyle(
                    color: style.foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: style.foregroundColor.withValues(alpha: 0.8),
                  size: 20,
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final IconData icon;

  const _NotificationStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.icon,
  });

  factory _NotificationStyle.fromType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const _NotificationStyle(
          backgroundColor: AppColors.primaryAccent,
          borderColor: AppColors.secondaryAccent,
          foregroundColor: Colors.white,
          icon: Icons.check_circle_rounded,
        );
      case NotificationType.error:
        return const _NotificationStyle(
          backgroundColor: Color(0xFF9B1C1C),
          borderColor: Color(0xFFB91C1C),
          foregroundColor: Colors.white,
          icon: Icons.error_rounded,
        );
      case NotificationType.warning:
        return const _NotificationStyle(
          backgroundColor: Color(0xFFB45309),
          borderColor: Color(0xFFD97706),
          foregroundColor: Colors.white,
          icon: Icons.warning_rounded,
        );
      case NotificationType.info:
        return const _NotificationStyle(
          backgroundColor: AppColors.cardSurface,
          borderColor: AppColors.borderLight,
          foregroundColor: AppColors.textPrimary,
          icon: Icons.info_rounded,
        );
    }
  }
}
