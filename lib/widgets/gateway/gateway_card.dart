import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../screens/gateway_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
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
  final int? seenAt;

  const _GatewayCardHeader({
    required this.gatewayId,
    required this.state,
    this.seenAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXl,
          ),
          child: const Icon(
            Icons.router_rounded,
            color: AppColors.primaryAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gatewayId,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (seenAt case final timestamp?) ...[
                const SizedBox(height: 2),
                Text(
                  formatDateTime(timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
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

  static bool _isAlertActive(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    return value != null;
  }

  static String _formatAlertText(String key, Object? value) {
    if (value is bool) return key;
    return '$key: $value';
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.entries
        .where((entry) => _isAlertActive(entry.value))
        .toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final alertTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
          letterSpacing: -0.2,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < activeAlerts.length; i++) ...[
          SizedBox(height: i == 0 ? 10 : 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatAlertText(
                      activeAlerts[i].key,
                      activeAlerts[i].value,
                    ),
                    style: alertTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
