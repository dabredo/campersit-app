import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class SensorAlertsList extends StatelessWidget {
  const SensorAlertsList({super.key, required this.alerts});

  final Map<String, Object?> alerts;

  static bool isAlertActive(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    return value != null;
  }

  static IconData resolveAlertIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('battery')) {
      return Icons.battery_alert_rounded;
    }
    if (lowerKey.contains('missing') ||
        lowerKey.contains('offline') ||
        lowerKey.contains('disconnect') ||
        lowerKey.contains('sensor')) {
      return Icons.sensors_off_rounded;
    }
    if (lowerKey.contains('camera') || lowerKey.contains('video')) {
      return Icons.videocam_off_rounded;
    }
    if (lowerKey.contains('motion') ||
        lowerKey.contains('crisis') ||
        lowerKey.contains('tamper') ||
        lowerKey.contains('vibration')) {
      return Icons.crisis_alert_rounded;
    }
    return Icons.warning_amber_rounded;
  }

  static String formatAlertText(String key, Object? value) {
    if (value is bool) {
      return 'Alarm: $key';
    }
    return 'Alarm: $key: $value';
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.entries
        .where((entry) => isAlertActive(entry.value))
        .toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final alertItemStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.danger,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < activeAlerts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  resolveAlertIcon(activeAlerts[i].key),
                  size: 15,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatAlertText(activeAlerts[i].key, activeAlerts[i].value),
                    style: alertItemStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
