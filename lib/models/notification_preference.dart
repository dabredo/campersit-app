import 'package:flutter/material.dart';

enum NotificationDeliveryChannel {
  none,
  app,
  email,
  both;

  bool get includesApp =>
      this == NotificationDeliveryChannel.app ||
      this == NotificationDeliveryChannel.both;

  bool get includesEmail =>
      this == NotificationDeliveryChannel.email ||
      this == NotificationDeliveryChannel.both;

  static NotificationDeliveryChannel fromBooleans({
    required bool app,
    required bool email,
  }) {
    if (app && email) return NotificationDeliveryChannel.both;
    if (app) return NotificationDeliveryChannel.app;
    if (email) return NotificationDeliveryChannel.email;
    return NotificationDeliveryChannel.none;
  }
}

class NotificationPreference {
  final String eventType;
  final bool app;
  final bool email;

  const NotificationPreference({
    required this.eventType,
    required this.app,
    required this.email,
  });

  NotificationDeliveryChannel get channel =>
      NotificationDeliveryChannel.fromBooleans(app: app, email: email);

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

class NotificationEventDefinition {
  final String type;
  final String title;
  final String description;
  final IconData icon;

  const NotificationEventDefinition({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<NotificationEventDefinition> allEvents = [
    NotificationEventDefinition(
      type: 'device-missing',
      title: 'Gateway Offline',
      description: 'Alert when a gateway loses connection or misses heartbeats.',
      icon: Icons.cloud_off_rounded,
    ),
    NotificationEventDefinition(
      type: 'device-not-missing',
      title: 'Gateway Online',
      description: 'Notice when an offline gateway reconnects and reports.',
      icon: Icons.cloud_done_rounded,
    ),
    NotificationEventDefinition(
      type: 'device-power-loss',
      title: 'Gateway Power Loss',
      description: 'Alert when main external power is disconnected.',
      icon: Icons.power_off_rounded,
    ),
    NotificationEventDefinition(
      type: 'device-power-restored',
      title: 'Gateway Power Restored',
      description: 'Notice when gateway power supply is restored.',
      icon: Icons.power_rounded,
    ),
    NotificationEventDefinition(
      type: 'device-initializing',
      title: 'Gateway Initializing',
      description: 'Notice when a gateway starts boot or setup cycle.',
      icon: Icons.sync_rounded,
    ),
    NotificationEventDefinition(
      type: 'sensor-triggered',
      title: 'Sensor Triggered',
      description: 'Alert when motion or a sensor event condition is triggered.',
      icon: Icons.motion_photos_on_rounded,
    ),
    NotificationEventDefinition(
      type: 'sensor-battery-low',
      title: 'Sensor Low Battery',
      description: 'Alert when a sensor battery level becomes low or critical.',
      icon: Icons.battery_alert_rounded,
    ),
    NotificationEventDefinition(
      type: 'sensor-missing',
      title: 'Sensor Offline',
      description: 'Alert when a sensor is unreachable or misses keep-alive.',
      icon: Icons.signal_wifi_off_rounded,
    ),
    NotificationEventDefinition(
      type: 'sensor-not-missing',
      title: 'Sensor Online',
      description: 'Notice when a sensor reconnects and resumes reporting.',
      icon: Icons.signal_wifi_4_bar_rounded,
    ),
  ];
}
