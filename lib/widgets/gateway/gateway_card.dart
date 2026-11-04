import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/gateway.dart';
import '../../providers/gateway_providers.dart';
import '../../screens/gateway_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../common/alerts_list.dart';
import '../common/app_action_button.dart';
import '../common/app_device_id_text.dart';
import '../common/app_device_type_badge.dart';
import '../common/app_seen_at_text.dart';
import 'delete_gateway_action.dart';
import 'gateway_location_section.dart';
import 'gateway_state_chip.dart';

class GatewayCard extends StatelessWidget {
  final Gateway gateway;

  const GatewayCard({super.key, required this.gateway});

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GatewayDetailScreen(
          gatewayId: gateway.id,
          initialGateway: gateway,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GatewayCardHeader(
                gatewayId: gateway.id,
                state: gateway.state,
                seenAt: gateway.seenAt,
                hasAlerts: gateway.alerts.values.any(AlertsList.isAlertActive),
              ),
              AlertsList(
                alerts: gateway.alerts,
                icon: Icons.warning_amber_rounded,
                topSpacing: 10,
              ),
              const SizedBox(height: 12),
              _GatewayActionsRow(gatewayId: gateway.id),
              const SizedBox(height: 12),
              _SensorsSummaryTile(sensorCount: gateway.sensors.length),
              GatewayLocationSection(gateway: gateway),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayCardHeader extends StatelessWidget {
  final String gatewayId;
  final String state;
  final int? seenAt;
  final bool hasAlerts;

  const _GatewayCardHeader({
    required this.gatewayId,
    required this.state,
    this.seenAt,
    this.hasAlerts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDeviceTypeBadge(
          icon: Icons.router_rounded,
          typeLabel: 'GATEWAY',
          hasAlerts: hasAlerts,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDeviceIdText(deviceId: gatewayId),
              const SizedBox(height: 2),
              AppSeenAtText(seenAt: seenAt),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GatewayStateChip(state: state),
      ],
    );
  }
}

class _SensorsSummaryTile extends StatelessWidget {
  final int sensorCount;

  const _SensorsSummaryTile({required this.sensorCount});

  @override
  Widget build(BuildContext context) {
    final countLabel =
        '$sensorCount ${sensorCount == 1 ? 'Sensor connected' : 'Sensors connected'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sensors_rounded,
            size: 18,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              countLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _GatewayActionsRow extends StatelessWidget {
  const _GatewayActionsRow({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ArmGatewayButton(gatewayId: gatewayId)),
        const SizedBox(width: 8),
        Expanded(child: _DisarmGatewayButton(gatewayId: gatewayId)),
        const SizedBox(width: 8),
        DeleteGatewayAction(gatewayId: gatewayId),
      ],
    );
  }
}

class _ArmGatewayButton extends ConsumerWidget {
  const _ArmGatewayButton({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(armGatewayControllerProvider(gatewayId))
        .isLoading;

    return AppActionButton(
      key: ValueKey('arm_gateway_$gatewayId'),
      label: 'Arm',
      icon: Icons.shield_outlined,
      backgroundColor: AppColors.armBackground,
      borderColor: AppColors.armBorder,
      foregroundColor: AppColors.armText,
      isLoading: isLoading,
      onPressed: () => ref
          .read(armGatewayControllerProvider(gatewayId).notifier)
          .armGateway(),
    );
  }
}

class _DisarmGatewayButton extends ConsumerWidget {
  const _DisarmGatewayButton({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(disarmGatewayControllerProvider(gatewayId))
        .isLoading;

    return AppActionButton(
      key: ValueKey('disarm_gateway_$gatewayId'),
      label: 'Disarm',
      icon: Icons.lock_open_rounded,
      backgroundColor: AppColors.cardSurface,
      borderColor: AppColors.buttonBorder,
      foregroundColor: AppColors.disarmText,
      isLoading: isLoading,
      onPressed: () => ref
          .read(disarmGatewayControllerProvider(gatewayId).notifier)
          .disarmGateway(),
    );
  }
}
