import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../providers/sensor_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../utils/sensor_icon_resolver.dart';
import '../widgets/common/app_device_id_text.dart';
import '../widgets/common/app_device_type_badge.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/sensor_tag_text.dart';

class ActuatorsScreen extends ConsumerWidget {
  final String gatewayId;
  final Sensor sensor;

  const ActuatorsScreen({
    super.key,
    required this.gatewayId,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewayAsync = ref.watch(singleGatewayProvider(gatewayId));
    final actuatorsCount = switch (gatewayAsync) {
      AsyncData(value: final gateway?) =>
        gateway.sensors.where((s) => s.isActuator).length,
      _ => null,
    };
    final title =
        actuatorsCount != null ? 'ACTUATORS ($actuatorsCount)' : 'ACTUATORS';

    return CustomScaffold(
      title: title,
      showBackButton: true,
      body: switch (gatewayAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => AppErrorState(
            title: 'Error loading configuration',
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(value: final gateway?) => _buildBody(gateway),
        AsyncData() => const AppErrorState(
            title: 'Error loading configuration',
            message: 'Gateway not found',
          ),
      },
    );
  }

  Widget _buildBody(Gateway gateway) {
    final currentMotionSensor = gateway.sensors.firstWhere(
      (s) => s.id == sensor.id,
      orElse: () => sensor,
    );
    final actuators = gateway.sensors.where((s) => s.isActuator).toList();

    return _ActuatorsContent(
      gatewayId: gatewayId,
      motionSensor: currentMotionSensor,
      actuators: actuators,
    );
  }
}

class _ActuatorsContent extends StatelessWidget {
  final String gatewayId;
  final Sensor motionSensor;
  final List<Sensor> actuators;

  const _ActuatorsContent({
    required this.gatewayId,
    required this.motionSensor,
    required this.actuators,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'Actuators for ${motionSensor.displayName}',
          subtitle:
              'These actuators will execute automatically when this sensor is triggered.',
        ),
        const SizedBox(height: 16),
        if (actuators.isEmpty)
          const AppEmptyState(
            icon: Icons.sensors_off_rounded,
            title: 'No Actuators Found',
            message:
                'Pair an actuator (camera, LED, or buzzer) to this gateway to configure trigger actions.',
          )
        else
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
    final isActionActive = motionSensor.actions.contains(actuator.id);

    final actionKey = (
      gatewayId: gatewayId,
      sensorId: motionSensor.id,
      actuatorId: actuator.id,
    );
    final controllerState =
        ref.watch(updateMotionActionControllerProvider(actionKey));
    final isUpdating = controllerState.isLoading;

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
          AppDeviceTypeBadge(
            icon: resolveSensorIcon(actuator.type),
            typeLabel: actuator.type.label,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDeviceIdText(deviceId: actuator.id),
                const SizedBox(height: 3),
                SensorTagText(tag: actuator.tag),
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
