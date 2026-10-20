import 'package:flutter/material.dart';

import '../models/sensor.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_formatter.dart';

class SensorCard extends StatelessWidget {
  final Sensor sensor;

  const SensorCard({super.key, required this.sensor});

  IconData _resolveSensorIcon(SensorType type) => switch (type) {
    SensorType.camera => Icons.videocam_rounded,
    SensorType.motion => Icons.motion_photos_on_rounded,
    SensorType.air => Icons.air_rounded,
    SensorType.led => Icons.lightbulb_rounded,
    SensorType.buzzer => Icons.volume_up_rounded,
    SensorType.unknown => Icons.sensors_rounded,
  };

  Color _resolveStateColor(SensorState state) => switch (state) {
    SensorState.triggered => Colors.redAccent,
    SensorState.enabled || SensorState.started => AppColors.primaryAccent,
    SensorState.paired => AppColors.secondaryAccent,
    SensorState.unpaired => const Color(0xFFD97706),
    SensorState.disabled => AppColors.textSecondary,
    SensorState.deleted => AppColors.textSecondary,
    SensorState.unknown => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final sensorIcon = _resolveSensorIcon(sensor.type);
    final hasTag = sensor.tag != null && sensor.tag!.trim().isNotEmpty;
    final displayName = hasTag ? sensor.tag!.trim() : sensor.id;
    final stateColor = _resolveStateColor(sensor.state);
    final isTriggered = sensor.state == SensorState.triggered;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(
          color: isTriggered ? Colors.redAccent : AppColors.borderLight,
          width: isTriggered ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      (isTriggered ? Colors.redAccent : AppColors.primaryAccent)
                          .withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderXl,
                ),
                child: Icon(
                  sensorIcon,
                  color: isTriggered
                      ? Colors.redAccent
                      : AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sensor.type.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (sensor.state != SensorState.unknown)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color: stateColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sensor.state.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stateColor,
                    ),
                  ),
                ),
            ],
          ),

          if (sensor.seenAt != null || sensor.battery != null) ...[
            const SizedBox(height: 8),
            _SensorFooter(seenAt: sensor.seenAt, battery: sensor.battery),
          ],
        ],
      ),
    );
  }
}

class _SensorFooter extends StatelessWidget {
  const _SensorFooter({this.seenAt, this.battery});

  final int? seenAt;
  final num? battery;

  @override
  Widget build(BuildContext context) {
    final seenAtTimestamp = seenAt;
    final batteryLevel = battery;

    return Row(
      children: [
        if (seenAtTimestamp != null)
          _SensorSeenAtIndicator(seenAt: seenAtTimestamp),
        const Spacer(),
        if (batteryLevel != null)
          _SensorBatteryIndicator(battery: batteryLevel),
      ],
    );
  }
}

class _SensorSeenAtIndicator extends StatelessWidget {
  const _SensorSeenAtIndicator({required this.seenAt});

  final int seenAt;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: AppColors.textSecondary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(formatDateTime(seenAt), style: textStyle),
      ],
    );
  }
}

class _SensorBatteryIndicator extends StatelessWidget {
  const _SensorBatteryIndicator({required this.battery});

  final num battery;

  static IconData _resolveBatteryIcon(num batteryLevel) {
    final isLow = batteryLevel > 100
        ? batteryLevel <= 1600
        : batteryLevel <= 20;
    if (isLow) return Icons.battery_0_bar_rounded;

    final isMedium = batteryLevel > 100
        ? batteryLevel <= 1800
        : batteryLevel <= 50;
    if (isMedium) return Icons.battery_3_bar_rounded;

    return Icons.battery_full_rounded;
  }

  static Color _resolveBatteryColor(num batteryLevel) {
    final isLow = batteryLevel > 100
        ? batteryLevel <= 1600
        : batteryLevel <= 20;
    if (isLow) return AppColors.danger;

    final isMedium = batteryLevel > 100
        ? batteryLevel <= 1800
        : batteryLevel <= 50;
    if (isMedium) return AppColors.warning;

    return AppColors.secondaryAccent;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveBatteryColor(battery);
    final textStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontWeight: FontWeight.w600, color: color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_resolveBatteryIcon(battery), size: 14, color: color),
        const SizedBox(width: 4),
        Text('${battery.toInt()}%', style: textStyle),
      ],
    );
  }
}
