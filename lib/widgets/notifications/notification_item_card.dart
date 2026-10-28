import 'package:flutter/material.dart';

import '../../models/gateway_notification.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';

class NotificationItemCard extends StatelessWidget {
  final GatewayNotification notification;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _resolveIcon() => switch (notification.type) {
    'sensor-triggered' => Icons.motion_photos_on_rounded,
    'sensor-triggered-off' => Icons.motion_photos_off_rounded,
    'sensor-started' => Icons.play_circle_outline_rounded,
    'sensor-started-off' => Icons.stop_circle_outlined,
    'sensor-battery-critical' => Icons.battery_alert_rounded,
    'sensor-battery-low' => Icons.battery_3_bar_rounded,
    'sensor-battery-good' => Icons.battery_full_rounded,
    'device-missing' || 'sensor-missing' => Icons.cloud_off_rounded,
    'device-not-missing' || 'sensor-not-missing' => Icons.cloud_done_rounded,
    'device-power-loss' => Icons.power_off_rounded,
    'device-power-restored' => Icons.power_rounded,
    'device-initializing' => Icons.sync_rounded,
    _ => Icons.notifications_rounded,
  };

  Color _resolveColor() => switch (notification.type) {
    'sensor-triggered' ||
    'sensor-battery-critical' ||
    'sensor-battery-low' ||
    'device-missing' ||
    'sensor-missing' ||
    'device-power-loss' => AppColors.danger,
    'device-not-missing' ||
    'device-power-restored' ||
    'sensor-not-missing' ||
    'sensor-battery-good' => AppColors.primaryAccent,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = _resolveColor();

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
              icon: _resolveIcon(),
              color: iconColor,
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
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
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
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _IdBadge(
          label: 'GW',
          value: notification.gatewayId,
          textTheme: textTheme,
        ),
        if (notification.isSensorRelated)
          _IdBadge(
            label: 'SENSOR',
            value: notification.sensorId!,
            textTheme: textTheme,
          ),
      ],
    );
  }
}

class _IdBadge extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;

  const _IdBadge({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
      ),
      child: Text(
        '$label: $value',
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
