import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensor.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_formatter.dart';

class SensorCard extends ConsumerWidget {
  final Sensor sensor;
  final String? gatewayId;
  final Future<bool> Function(String newTag)? onUpdateTag;

  const SensorCard({
    super.key,
    required this.sensor,
    this.gatewayId,
    this.onUpdateTag,
  });

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
    final currentGatewayId = gatewayId;
    final saveCallback =
        onUpdateTag ??
        (currentGatewayId != null
            ? (newTag) => ref
                  .read(
                    updateSensorTagControllerProvider(currentGatewayId)
                        .notifier,
                  )
                  .updateTag(sensorId: sensor.id, tag: newTag)
            : null);

    if (saveCallback == null) return;

    await showDialog<void>(
      context: context,
      builder: (_) => _EditSensorTagDialog(
        initialTag: sensor.tag,
        sensorId: sensor.id,
        onSave: saveCallback,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          color: isTriggered ? AppColors.danger : AppColors.borderLight,
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
                      (isTriggered ? AppColors.danger : AppColors.primaryAccent)
                          .withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderXl,
                ),
                child: Icon(
                  sensorIcon,
                  color: isTriggered
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
                        if (gatewayId != null || onUpdateTag != null) ...[
                          const SizedBox(width: 4),
                          _EditSensorTagButton(
                            sensorId: sensor.id,
                            onTap: () => _showEditTagDialog(context, ref),
                          ),
                        ],
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
