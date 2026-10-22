import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensor.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_formatter.dart';

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
    SensorState.triggered => Colors.redAccent,
    SensorState.enabled || SensorState.started => AppColors.primaryAccent,
    SensorState.paired => AppColors.secondaryAccent,
    SensorState.unpaired => const Color(0xFFD97706),
    SensorState.disabled => AppColors.textSecondary,
    SensorState.deleted => AppColors.textSecondary,
    SensorState.unknown => AppColors.textSecondary,
  };

  Future<void> _showEditTagDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _EditSensorTagDialog(
        initialTag: sensor.tag,
        sensorId: sensor.id,
        onSave: (newTag) => ref
            .read(updateSensorTagControllerProvider(gatewayId).notifier)
            .updateTag(sensorId: sensor.id, tag: newTag),
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
          builder: (_) => _DeleteSensorDialog(sensorName: sensorName),
        ) ??
        false;

    if (!isConfirmed || !context.mounted) return;

    await ref
        .read(deleteSensorControllerProvider(gatewayId).notifier)
        .deleteSensor(sensor.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorIcon = _resolveSensorIcon(sensor.type);
    final hasTag = sensor.tag != null && sensor.tag!.trim().isNotEmpty;
    final displayName = hasTag ? sensor.tag!.trim() : sensor.id;
    final stateColor = _resolveStateColor(sensor.state);
    final hasActiveAlerts =
        sensor.alerts.values.any(_SensorAlertsList.isAlertActive);
    final isTriggered = sensor.state == SensorState.triggered;
    final isAlerting = isTriggered || hasActiveAlerts;
    final isDeleting = ref.watch(
      deleteSensorControllerProvider(gatewayId)
          .select((deletingSensorId) => deletingSensorId == sensor.id),
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
                        _EditSensorTagButton(
                          sensorId: sensor.id,
                          onTap: () => _showEditTagDialog(context, ref),
                        ),
                        const SizedBox(width: 4),
                        _DeleteSensorButton(
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stateColor,
                    ),
                  ),
                ),
            ],
          ),

          if (hasActiveAlerts) ...[
            const SizedBox(height: 10),
            _SensorAlertsList(alerts: sensor.alerts),
          ],

          if (sensor.seenAt != null || sensor.battery != null) ...[
            const SizedBox(height: 8),
            _SensorFooter(seenAt: sensor.seenAt, battery: sensor.battery),
          ],
        ],
      ),
    );
  }
}

class _SensorAlertsList extends StatelessWidget {
  const _SensorAlertsList({required this.alerts});

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

enum _BatteryStatus {
  low,
  medium,
  full;

  // IoT sensors report battery either in millivolts (> 100) or percentage (0-100)
  static const num _mvThreshold = 100;
  static const num _lowMv = 1600;
  static const num _mediumMv = 1800;
  static const num _lowPercent = 20;
  static const num _mediumPercent = 50;

  factory _BatteryStatus.fromLevel(num value) {
    final isMillivolts = value > _mvThreshold;
    if (isMillivolts ? value <= _lowMv : value <= _lowPercent) {
      return _BatteryStatus.low;
    }
    if (isMillivolts ? value <= _mediumMv : value <= _mediumPercent) {
      return _BatteryStatus.medium;
    }
    return _BatteryStatus.full;
  }

  IconData get icon => switch (this) {
    _BatteryStatus.low => Icons.battery_0_bar_rounded,
    _BatteryStatus.medium => Icons.battery_3_bar_rounded,
    _BatteryStatus.full => Icons.battery_full_rounded,
  };

  Color get color => switch (this) {
    _BatteryStatus.low => AppColors.danger,
    _BatteryStatus.medium => AppColors.warning,
    _BatteryStatus.full => AppColors.secondaryAccent,
  };
}

class _SensorBatteryIndicator extends StatelessWidget {
  const _SensorBatteryIndicator({required this.battery});

  final num battery;

  @override
  Widget build(BuildContext context) {
    final status = _BatteryStatus.fromLevel(battery);
    final textStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontWeight: FontWeight.w600, color: status.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 14, color: status.color),
        const SizedBox(width: 4),
        Text('${battery.toInt()}', style: textStyle),
      ],
    );
  }
}

class _EditSensorTagButton extends StatelessWidget {
  const _EditSensorTagButton({required this.sensorId, required this.onTap});

  final String sensorId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('edit_sensor_tag_$sensorId'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.edit_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DeleteSensorButton extends StatelessWidget {
  const _DeleteSensorButton({
    required this.sensorId,
    required this.onTap,
    this.isLoading = false,
  });

  final String sensorId;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.danger,
        ),
      );
    }

    return InkWell(
      key: ValueKey('delete_sensor_$sensorId'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 14,
          color: AppColors.danger,
        ),
      ),
    );
  }
}

class _DeleteSensorDialog extends StatelessWidget {
  const _DeleteSensorDialog({required this.sensorName});

  final String sensorName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      title: Text(
        'Delete Sensor',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "$sensorName"? This will unpair the sensor from the gateway.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _EditSensorTagDialog extends StatefulWidget {
  const _EditSensorTagDialog({
    required this.initialTag,
    required this.sensorId,
    required this.onSave,
  });

  final String? initialTag;
  final String sensorId;
  final Future<bool> Function(String newTag) onSave;

  @override
  State<_EditSensorTagDialog> createState() => _EditSensorTagDialogState();
}

class _EditSensorTagDialogState extends State<_EditSensorTagDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTag ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    final success = await widget.onSave(_controller.text.trim());
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      title: const Text(
        'Edit Sensor Tag',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sensor ID: ${widget.sensorId}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tag',
              hintText: 'e.g. Living Room, Cabin',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
            onFieldSubmitted: _isLoading ? null : (_) => _handleSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
