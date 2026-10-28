import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NotificationEventDefinition {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const NotificationEventDefinition({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.color = AppColors.textSecondary,
  });

  static const List<NotificationEventDefinition> allEvents = [
    NotificationEventDefinition(
      type: 'device-initializing',
      title: 'Gateway Initializing',
      description: 'Notice when a gateway starts boot or setup cycle.',
      icon: Icons.sync_rounded,
      color: AppColors.textSecondary,
    ),
    NotificationEventDefinition(
      type: 'device-missing',
      title: 'Gateway Offline',
      description: 'Alert when a gateway loses connection or misses heartbeats.',
      icon: Icons.cloud_off_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'device-not-missing',
      title: 'Gateway Online',
      description: 'Notice when an offline gateway reconnects and reports.',
      icon: Icons.cloud_done_rounded,
      color: AppColors.primaryAccent,
    ),
    NotificationEventDefinition(
      type: 'device-power-loss',
      title: 'Gateway Power Loss',
      description: 'Alert when main external power is disconnected.',
      icon: Icons.power_off_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'device-power-restored',
      title: 'Gateway Power Restored',
      description: 'Notice when gateway power supply is restored.',
      icon: Icons.power_rounded,
      color: AppColors.primaryAccent,
    ),
    NotificationEventDefinition(
      type: 'sensor-missing',
      title: 'Sensor Offline',
      description: 'Alert when a sensor is unreachable or misses keep-alive.',
      icon: Icons.signal_wifi_off_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'sensor-not-missing',
      title: 'Sensor Online',
      description: 'Notice when a sensor reconnects and resumes reporting.',
      icon: Icons.signal_wifi_4_bar_rounded,
      color: AppColors.primaryAccent,
    ),
    NotificationEventDefinition(
      type: 'sensor-started',
      title: 'Actuator Started',
      description: 'Alert when an actuator starts running (camera, siren, or LED).',
      icon: Icons.play_circle_outline_rounded,
      color: AppColors.textSecondary,
    ),
    NotificationEventDefinition(
      type: 'sensor-started-off',
      title: 'Actuator Stopped',
      description: 'Notice when an actuator finishes running or is stopped.',
      icon: Icons.stop_circle_outlined,
      color: AppColors.textSecondary,
    ),
    NotificationEventDefinition(
      type: 'sensor-triggered',
      title: 'Sensor Triggered',
      description: 'Alert when motion or an environmental condition is triggered.',
      icon: Icons.motion_photos_on_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'sensor-triggered-off',
      title: 'Sensor Trigger Cleared',
      description: 'Notice when a triggered sensor event is cleared or cooldown ends.',
      icon: Icons.motion_photos_off_rounded,
      color: AppColors.textSecondary,
    ),
    NotificationEventDefinition(
      type: 'sensor-battery-critical',
      title: 'Sensor Battery Critical',
      description: 'Alert when a sensor battery level reaches critical state.',
      icon: Icons.battery_alert_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'sensor-battery-low',
      title: 'Sensor Battery Low',
      description: 'Alert when a sensor battery level becomes low.',
      icon: Icons.battery_3_bar_rounded,
      color: AppColors.danger,
    ),
    NotificationEventDefinition(
      type: 'sensor-battery-good',
      title: 'Sensor Battery Normal',
      description: 'Notice when a sensor battery returns to normal or is replaced.',
      icon: Icons.battery_full_rounded,
      color: AppColors.primaryAccent,
    ),
  ];

  static final Map<String, NotificationEventDefinition> _eventsByType = {
    for (final event in allEvents) event.type: event,
  };

  static NotificationEventDefinition forType(String type) {
    return _eventsByType[type] ??
        NotificationEventDefinition(
          type: type,
          title: type.replaceAll('-', ' ').trim(),
          description: '',
          icon: Icons.notifications_rounded,
          color: AppColors.textSecondary,
        );
  }
}
