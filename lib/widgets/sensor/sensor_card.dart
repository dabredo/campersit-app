import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sensor.dart';
import '../../providers/sensor_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/sensor_icon_resolver.dart';
import '../common/app_confirm_dialog.dart';
import 'sensor_card/air_sensor_values.dart';
import 'sensor_card/camera_recordings_button.dart';
import 'sensor_card/motion_actions_button.dart';
import 'sensor_card/sensor_action_buttons.dart';
import 'sensor_card/sensor_alerts_list.dart';
import 'sensor_card/sensor_dialogs.dart';
import 'sensor_card/sensor_footer.dart';

export 'sensor_card/air_sensor_values.dart';
export 'sensor_card/camera_recordings_button.dart';
export 'sensor_card/motion_actions_button.dart';
export 'sensor_card/sensor_action_buttons.dart';
export 'sensor_card/sensor_alerts_list.dart';
export 'sensor_card/sensor_dialogs.dart';
export 'sensor_card/sensor_footer.dart';

class SensorCard extends ConsumerWidget {
  final Sensor sensor;
  final String gatewayId;

  const SensorCard({super.key, required this.sensor, required this.gatewayId});

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
            .read(
              updateSensorTagControllerProvider((
                gatewayId: gatewayId,
                sensorId: sensor.id,
              )).notifier,
            )
            .updateTag(newTag),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Sensor',
      content:
          'Are you sure you want to delete "${sensor.displayName}"? This will unpair the sensor from the gateway.',
    );

    if (!isConfirmed || !context.mounted) return;

    await ref
        .read(
          deleteSensorControllerProvider((
            gatewayId: gatewayId,
            sensorId: sensor.id,
          )).notifier,
        )
        .deleteSensor();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorIcon = resolveSensorIcon(sensor.type);
    final displayName = sensor.displayName;
    final stateColor = _resolveStateColor(sensor.state);
    final hasActiveAlerts = sensor.alerts.values.any(
      SensorAlertsList.isAlertActive,
    );
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isAlerting
                              ? AppColors.danger
                              : AppColors.primaryAccent)
                          .withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderXl,
                    ),
                    child: Icon(
                      sensorIcon,
                      color: isAlerting
                          ? AppColors.danger
                          : AppColors.primaryAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      sensor.type.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (sensor.tag case final tag? when tag.isNotEmpty)
                                Text(
                                  sensor.id,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (sensor.seenAt case final seenAt?) ...[
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      formatDateTime(seenAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontFamily: 'monospace',
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    if (sensor.battery case final battery?) ...[
                                      const SizedBox(width: 6),
                                      SensorBatteryIndicator(battery: battery),
                                    ],
                                  ],
                                ),
                              ] else if (sensor.battery case final battery?) ...[
                                const SizedBox(height: 2),
                                SensorBatteryIndicator(battery: battery),
                              ],
                            ],
                          ),
                        ),
                        if (sensor.state != SensorState.unknown) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isAlerting
                                      ? AppColors.danger
                                      : stateColor)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: (isAlerting
                                        ? AppColors.danger
                                        : stateColor)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isAlerting
                                        ? AppColors.danger
                                        : stateColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sensor.state.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isAlerting
                                            ? AppColors.danger
                                            : stateColor,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (sensor.type == SensorType.air &&
              (sensor.temperature != null || sensor.humidity != null)) ...[
            const SizedBox(height: 12),
            AirSensorValues(
              temperature: sensor.temperature,
              humidity: sensor.humidity,
            ),
          ],

          if (hasActiveAlerts) ...[
            const SizedBox(height: 10),
            SensorAlertsList(alerts: sensor.alerts),
          ],

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (sensor.availableTransitions.isNotEmpty)
                        SensorActionButtons(
                          sensor: sensor,
                          gatewayId: gatewayId,
                        ),
                      if (sensor.type == SensorType.camera)
                        CameraRecordingsButton(
                          gatewayId: gatewayId,
                          sensor: sensor,
                        ),
                      if (sensor.type == SensorType.motion)
                        MotionActionsButton(
                          gatewayId: gatewayId,
                          sensor: sensor,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DeleteSensorButton(
                  sensorId: sensor.id,
                  isLoading: isDeleting,
                  onTap: isDeleting
                      ? () {}
                      : () => _confirmAndDelete(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
