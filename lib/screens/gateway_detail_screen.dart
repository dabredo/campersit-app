import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/common/app_loading_state.dart';
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/section_header.dart';
import '../widgets/gateway/sensors_sliver.dart';

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

    return CustomScaffold(
      title: 'SENSORS',
      showBackButton: true,
      body: switch (gatewayAsync) {
        AsyncLoading() => const AppLoadingState(),
        AsyncError(:final error) => AppErrorState(
          title: 'Error loading gateway details',
          message: AppErrorFormatter.format(error),
        ),
        AsyncData() => const AppErrorState(
          title: 'Gateway not found',
          message: 'Gateway not found.',
        ),
      },
    );
  }
}

class _GatewayDetailContent extends StatelessWidget {
  const _GatewayDetailContent({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'SENSORS (${gateway.sensors.length})',
      showBackButton: true,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Sensors for ${gateway.id}',
                subtitle:
                    'Manage and monitor all devices connected to this gateway.',
              ),
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
    );
  }
}
