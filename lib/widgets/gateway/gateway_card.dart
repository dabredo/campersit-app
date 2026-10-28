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
              _buildHeader(),
              _buildAlertsSection(context, gateway),
              const SizedBox(height: 12),
              _buildSensorsSummaryTile(context, gateway),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorsSummaryTile(BuildContext context, Gateway gateway) {
    final sensorCount = gateway.sensors.length;
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            gateway.id,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GatewayStateChip(state: gateway.state),
      ],
    );
  }

  Widget _buildAlertsSection(BuildContext context, Gateway gateway) {
    if (gateway.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Alarms:', style: Theme.of(context).textTheme.titleSmall),
        ...gateway.alerts.entries.map(
          (e) => Text(
            '- ${e.key}: ${e.value}',
            style: const TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
