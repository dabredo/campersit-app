import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../screens/gateway_detail_screen.dart';
import '../../theme/app_theme.dart';
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
              ),
              _GatewayAlertsSection(alerts: gateway.alerts),
              const SizedBox(height: 12),
              _SensorsSummaryTile(sensorCount: gateway.sensors.length),
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

  const _GatewayCardHeader({
    required this.gatewayId,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            gatewayId,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GatewayStateChip(state: state),
      ],
    );
  }
}

class _GatewayAlertsSection extends StatelessWidget {
  final Map<String, Object?> alerts;

  const _GatewayAlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Alarms:', style: textTheme.titleSmall),
        for (final entry in alerts.entries)
          Text(
            '- ${entry.key}: ${entry.value}',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.danger,
            ),
          ),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: AppColors.primaryAccent,
          ),
        ],
      ),
    );
  }
}
