import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gateway_providers.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/add_device_card.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/common/app_loading_state.dart';
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/section_header.dart';
import '../widgets/gateway/add_gateway_bottom_sheet.dart';
import '../widgets/gateway/gateway_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsyncValue = ref.watch(userGatewaysProvider);
    final gateways = gatewaysAsyncValue.value;
    final title =
        gateways != null ? 'GATEWAYS (${gateways.length})' : 'GATEWAYS';

    return CustomScaffold(
      title: title,
      showBottomNavBar: false,
      body: switch (gatewaysAsyncValue) {
        AsyncLoading() => const AppLoadingState(),
        AsyncError(:final error) => AppErrorState(
          title: 'Error loading gateways',
          message: AppErrorFormatter.format(error),
        ),
        AsyncData(value: final gateways) => ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          children: [
            const SectionHeader(
              title: 'Registered Gateways',
              subtitle: 'Manage and monitor your connected IoT gateways.',
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 8),
            if (gateways.isEmpty) ...[
              const AppEmptyState(
                icon: Icons.router_rounded,
                title: 'No Gateways',
                message: 'You currently have no gateways configured.',
              ),
              const SizedBox(height: 12),
            ] else
              for (final gateway in gateways) GatewayCard(gateway: gateway),
            const _AddGatewayCard(),
          ],
        ),
      },
    );
  }
}

class _AddGatewayCard extends StatelessWidget {
  const _AddGatewayCard();

  @override
  Widget build(BuildContext context) {
    return AddDeviceCard(
      title: 'Add Gateway',
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => AddGatewayBottomSheet.show(context),
    );
  }
}
