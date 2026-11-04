import 'package:flutter/material.dart';

import '../../models/gateway_notification.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../common/app_device_id_text.dart';

class NotificationItemCard extends StatelessWidget {
  final GatewayNotification notification;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final definition = notification.definition;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.border2Xl,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: AppRadius.border2Xl,
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIconBadge(
              icon: definition.icon,
              color: definition.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.typeLabel,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatDateTime(notification.createdAt),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _NotificationDetailsRow(notification: notification),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NotificationIconBadge({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderXl,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

class _NotificationDetailsRow extends StatelessWidget {
  final GatewayNotification notification;

  const _NotificationDetailsRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    final sensorId = notification.sensorId;
    final deviceId = (sensorId != null && sensorId.isNotEmpty)
        ? sensorId
        : notification.gatewayId;

    return AppDeviceIdText(deviceId: deviceId);
  }
}
