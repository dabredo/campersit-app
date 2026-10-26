import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/gateway/delete_gateway_action.dart';
import '../widgets/gateway/gateway_overview_card.dart';
import '../widgets/gateway/sensors_sliver.dart';
import '../widgets/sensor/add_sensor_bottom_sheet.dart';

class GatewayDetailScreen extends ConsumerWidget {
  const GatewayDetailScreen({
    super.key,
    required this.gatewayId,
    this.initialGateway,
  });

  final String gatewayId;
  final Gateway? initialGateway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewayAsync = ref.watch(singleGatewayProvider(gatewayId));

    if (gatewayAsync.value ?? initialGateway case final gateway?) {
      return _GatewayDetailContent(gateway: gateway);
    }

    return switch (gatewayAsync) {
      AsyncLoading() => _GatewayMessageScaffold(
        title: gatewayId,
        body: const CircularProgressIndicator(color: AppColors.primaryAccent),
      ),
      AsyncError(:final error) => _GatewayMessageScaffold(
        title: gatewayId,
        body: _CenteredMessage(
          'Error loading gateway details:\n${AppErrorFormatter.format(error)}',
          color: AppColors.danger,
        ),
      ),
      AsyncData() => const _GatewayMessageScaffold(
        title: 'Gateway Details',
        body: _CenteredMessage('Gateway not found.'),
      ),
    };
  }
}

class _GatewayMessageScaffold extends StatelessWidget {
  const _GatewayMessageScaffold({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(title: Text(title)),
      body: Center(child: body),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message, {this.color = AppColors.textSecondary});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

class _GatewayDetailContent extends StatelessWidget {
  const _GatewayDetailContent({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text(gateway.id),
        actions: [
          DeleteGatewayAction(gatewayId: gateway.id),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList.list(
              children: [
                GatewayOverviewCard(gateway: gateway),
                const SizedBox(height: 20),
                SensorsSectionHeader(sensorCount: gateway.sensors.length),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
            sliver: SensorsSliver(
              gatewayId: gateway.id,
              sensors: gateway.sensors,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.cardSurface,
        tooltip: 'Add Sensor',
        onPressed: () =>
            AddSensorBottomSheet.show(context, gatewayId: gateway.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}
