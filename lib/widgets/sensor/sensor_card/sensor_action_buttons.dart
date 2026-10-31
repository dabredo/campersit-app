import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/sensor.dart';
import '../../../providers/sensor_providers.dart';
import '../../../theme/app_theme.dart';
import '../../common/app_action_button.dart';

class SensorActionButtons extends ConsumerWidget {
  const SensorActionButtons({
    super.key,
    required this.sensor,
    required this.gatewayId,
  });

  final Sensor sensor;
  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTarget = ref.watch(
      requestSensorStateControllerProvider((
        gatewayId: gatewayId,
        sensorId: sensor.id,
      )),
    );
    final transitions = sensor.availableTransitions;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final transition in transitions)
          SensorStateButton(
            gatewayId: gatewayId,
            sensorId: sensor.id,
            targetState: transition,
            isLoading: activeTarget == transition,
            isDisabled: activeTarget != null,
          ),
      ],
    );
  }
}

class SensorStateButton extends ConsumerWidget {
  const SensorStateButton({
    super.key,
    required this.gatewayId,
    required this.sensorId,
    required this.targetState,
    required this.isLoading,
    required this.isDisabled,
  });

  final String gatewayId;
  final String sensorId;
  final SensorState targetState;
  final bool isLoading;
  final bool isDisabled;

  static String _resolveLabel(SensorState state) => switch (state) {
    SensorState.enabled => 'Enable',
    SensorState.started => 'Start',
    SensorState.paired => 'Pair',
    _ => state.label,
  };

  static IconData _resolveIcon(SensorState state) => switch (state) {
    SensorState.enabled => Icons.power_settings_new_rounded,
    SensorState.started => Icons.play_arrow_rounded,
    SensorState.paired => Icons.link_rounded,
    _ => Icons.arrow_forward_rounded,
  };

  static Color _resolveColor(SensorState state) => switch (state) {
    SensorState.enabled => AppColors.primaryAccent,
    SensorState.started => AppColors.secondaryAccent,
    SensorState.paired => AppColors.textSecondary,
    _ => AppColors.textPrimary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _resolveColor(targetState);
    final label = _resolveLabel(targetState);
    final icon = _resolveIcon(targetState);

    return AppActionButton(
      label: label,
      icon: icon,
      foregroundColor: color,
      backgroundColor: AppColors.cardSurface,
      borderColor: AppColors.borderLight,
      isLoading: isLoading,
      onPressed: isDisabled
          ? null
          : () => ref
              .read(
                requestSensorStateControllerProvider((
                  gatewayId: gatewayId,
                  sensorId: sensorId,
                )).notifier,
              )
              .requestState(targetState),
    );
  }
}
