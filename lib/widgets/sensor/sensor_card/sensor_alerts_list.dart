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

  static String formatAlertText(String key, Object? value) {
    if (value is bool) {
      return '- $key';
    }
    return '- $key: $value';
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.entries
        .where((entry) => isAlertActive(entry.value))
        .toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final alertTitleStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.danger,
    );
    final alertItemStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.danger,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: AppColors.danger,
              ),
              const SizedBox(width: 4),
              Text('Alarms:', style: alertTitleStyle),
            ],
          ),
          const SizedBox(height: 4),
          for (final entry in activeAlerts)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Text(
                formatAlertText(entry.key, entry.value),
                style: alertItemStyle,
              ),
            ),
        ],
      ),
    );
  }
}
