import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sensor.dart';
import '../../providers/sensor_providers.dart';
import '../../theme/app_theme.dart';
import 'sensor_card/air_sensor_values.dart';
import 'sensor_card/sensor_action_buttons.dart';
import 'sensor_card/sensor_alerts_list.dart';
import 'sensor_card/sensor_dialogs.dart';
import 'sensor_card/sensor_footer.dart';

export 'sensor_card/air_sensor_values.dart';
export 'sensor_card/sensor_action_buttons.dart';
export 'sensor_card/sensor_alerts_list.dart';
export 'sensor_card/sensor_dialogs.dart';
export 'sensor_card/sensor_footer.dart';

class SensorCard extends ConsumerWidget {
  final Sensor sensor;
  final String gatewayId;

  const SensorCard({super.key, required this.sensor, required this.gatewayId});

  IconData _resolveSensorIcon(SensorType type) => switch (type) {
    SensorType.camera => Icons.videocam_rounded,
    SensorType.motion => Icons.motion_photos_on_rounded,
    SensorType.air => Icons.air_rounded,
    SensorType.led => Icons.lightbulb_rounded,
    SensorType.buzzer => Icons.volume_up_rounded,
    SensorType.unknown => Icons.sensors_rounded,
  };

  Color _resolveStateColor(SensorState state) => switch (state) {
    SensorState.triggered => AppColors.danger,
    SensorState.enabled || SensorState.started => AppColors.primaryAccent,
    SensorState.paired => AppColors.secondaryAccent,
    SensorState.unpaired => AppColors.warning,
    SensorState.disabled => AppColors.textSecondary,
    SensorState.deleted => AppColors.textSecondary,
    SensorState.unknown => AppColors.textSecondary,
  };

  Future<void> _showEditTagDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => EditSensorTagDialog(
        initialTag: sensor.tag,
        sensorId: sensor.id,
        onSave: (newTag) => ref
            .read(updateSensorTagControllerProvider((
              gatewayId: gatewayId,
              sensorId: sensor.id,
            )).notifier)
            .updateTag(newTag),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final sensorTag = sensor.tag?.trim();
    final sensorName = (sensorTag != null && sensorTag.isNotEmpty)
        ? sensorTag
        : sensor.id;

    final isConfirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => DeleteSensorDialog(sensorName: sensorName),
        ) ??
        false;

    if (!isConfirmed || !context.mounted) return;

    await ref
        .read(deleteSensorControllerProvider((
          gatewayId: gatewayId,
          sensorId: sensor.id,
        )).notifier)
        .deleteSensor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorIcon = _resolveSensorIcon(sensor.type);
    final hasTag = sensor.tag != null && sensor.tag!.trim().isNotEmpty;
    final displayName = hasTag ? sensor.tag!.trim() : sensor.id;
    final stateColor = _resolveStateColor(sensor.state);
    final hasActiveAlerts =
        sensor.alerts.values.any(SensorAlertsList.isAlertActive);
    final isTriggered = sensor.state == SensorState.triggered;
    final isAlerting = isTriggered || hasActiveAlerts;
    final isDeleting = ref.watch(
      deleteSensorControllerProvider((
        gatewayId: gatewayId,
        sensorId: sensor.id,
      )),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(
          color: isAlerting ? AppColors.danger : AppColors.borderLight,
          width: isAlerting ? 1.5 : 1,
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
                      (isAlerting ? AppColors.danger : AppColors.primaryAccent)
                          .withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderXl,
                ),
                child: Icon(
                  sensorIcon,
                  color: isAlerting
                      ? AppColors.danger
                      : AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        EditSensorTagButton(
                          sensorId: sensor.id,
                          onTap: () => _showEditTagDialog(context, ref),
                        ),
                        const SizedBox(width: 4),
                        DeleteSensorButton(
                          sensorId: sensor.id,
                          isLoading: isDeleting,
                          onTap: isDeleting
                              ? () {}
                              : () => _confirmAndDelete(context, ref),
                        ),
                      ],
                    ),
                    Text(
                      sensor.type.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: stateColor,
                    ),
                  ),
                ),
            ],
          ),

          if (sensor.type == SensorType.air &&
              (sensor.temperature != null || sensor.humidity != null)) ...[
            const SizedBox(height: 10),
            AirSensorValues(
              temperature: sensor.temperature,
              humidity: sensor.humidity,
            ),
          ],

          if (hasActiveAlerts) ...[
            const SizedBox(height: 10),
            SensorAlertsList(alerts: sensor.alerts),
          ],

          if (sensor.availableTransitions.isNotEmpty) ...[
            const SizedBox(height: 10),
            SensorActionButtons(
              sensor: sensor,
              gatewayId: gatewayId,
            ),
          ],

          if (sensor.seenAt != null || sensor.battery != null) ...[
            const SizedBox(height: 8),
            SensorFooter(seenAt: sensor.seenAt, battery: sensor.battery),
          ],
        ],
      ),
    );
  }
}
