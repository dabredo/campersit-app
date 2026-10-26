import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../providers/sensor_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../utils/sensor_icon_resolver.dart';

class MotionConfigScreen extends ConsumerWidget {
  final String gatewayId;
  final Sensor sensor;

  const MotionConfigScreen({
    super.key,
    required this.gatewayId,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (sensor.tag != null && sensor.tag!.trim().isNotEmpty)
        ? sensor.tag!.trim()
        : sensor.id;

    final gatewayAsync = ref.watch(singleGatewayProvider(gatewayId));

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('$title Actions'),
      ),
      body: switch (gatewayAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => _MotionConfigError(
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(value: final gateway?) => _buildBody(gateway),
        AsyncData() => const _MotionConfigError(
            message: 'Gateway not found',
          ),
      },
    );
  }

  Widget _buildBody(Gateway gateway) {
    // Resolve the real-time sensor from gateway sensors stream to keep actions in sync
    final currentMotionSensor = gateway.sensors.firstWhere(
      (s) => s.id == sensor.id,
      orElse: () => sensor,
    );
    final actuators = gateway.sensors.where((s) => s.isActuator).toList();

    if (actuators.isEmpty) {
      return const _MotionConfigEmpty();
    }

    return _MotionConfigContent(
      gatewayId: gatewayId,
      motionSensor: currentMotionSensor,
      actuators: actuators,
    );
  }
}

class _MotionConfigContent extends StatelessWidget {
  final String gatewayId;
  final Sensor motionSensor;
  final List<Sensor> actuators;

  const _MotionConfigContent({
    required this.gatewayId,
    required this.motionSensor,
    required this.actuators,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MotionConfigHeader(motionSensor: motionSensor),
        const SizedBox(height: 20),
        Text(
          'PAIRED ACTUATORS (${actuators.length})',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < actuators.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ActuatorActionTile(
            gatewayId: gatewayId,
            motionSensor: motionSensor,
            actuator: actuators[i],
          ),
        ],
      ],
    );
  }
}

class _MotionConfigHeader extends StatelessWidget {
  final Sensor motionSensor;

  const _MotionConfigHeader({required this.motionSensor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderXl,
            ),
            child: Icon(
              resolveSensorIcon(motionSensor.type),
              color: AppColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Trigger Actions',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose which actuators trigger automatically when movement is detected by this sensor.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActuatorActionTile extends ConsumerWidget {
  final String gatewayId;
  final Sensor motionSensor;
  final Sensor actuator;

  const _ActuatorActionTile({
    required this.gatewayId,
    required this.motionSensor,
    required this.actuator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isActionActive = motionSensor.actions.contains(actuator.id);

    final actionKey = (
      gatewayId: gatewayId,
      sensorId: motionSensor.id,
      actuatorId: actuator.id,
    );
    final controllerState =
        ref.watch(updateMotionActionControllerProvider(actionKey));
    final isUpdating = controllerState.isLoading;

    final hasTag = actuator.tag != null && actuator.tag!.trim().isNotEmpty;
    final displayName = hasTag ? actuator.tag!.trim() : actuator.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(
          color: isActionActive
              ? AppColors.primaryAccent.withValues(alpha: 0.35)
              : AppColors.borderLight,
          width: isActionActive ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isActionActive
                      ? AppColors.primaryAccent
                      : AppColors.textSecondary)
                  .withValues(alpha: 0.1),
              borderRadius: AppRadius.borderXl,
            ),
            child: Icon(
              resolveSensorIcon(actuator.type),
              color: isActionActive
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary,
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
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      actuator.type.label.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'ID: ${actuator.id}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpdating)
            const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            )
          else
            Switch.adaptive(
              key: ValueKey('actuator_switch_${actuator.id}'),
              value: isActionActive,
              activeTrackColor: AppColors.primaryAccent,
              onChanged: (enabled) {
                ref
                    .read(updateMotionActionControllerProvider(actionKey).notifier)
                    .setActionEnabled(enabled);
              },
            ),
        ],
      ),
    );
  }
}

class _MotionConfigEmpty extends StatelessWidget {
  const _MotionConfigEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.sensors_off_rounded,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Actuators Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pair an actuator (camera, LED, or buzzer) to this gateway to configure trigger actions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotionConfigError extends StatelessWidget {
  final String message;

  const _MotionConfigError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading configuration',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
