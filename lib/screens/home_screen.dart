import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/add_device_card.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/gateway/add_gateway_bottom_sheet.dart';
import '../widgets/gateway/gateway_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsyncValue = ref.watch(userGatewaysProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const AppAppBar(title: 'Gateways'),
      body: gatewaysAsyncValue.when(
        data: (gateways) {
          if (gateways.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: const [
                AppEmptyState(
                  icon: Icons.router_rounded,
                  title: 'No Gateways',
                  message: 'You currently have no gateways configured.',
                ),
                SizedBox(height: 12),
                _AddGatewayCard(),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: gateways.length + 1,
            itemBuilder: (context, index) {
              if (index < gateways.length) {
                return GatewayCard(gateway: gateways[index]);
              }
              return const _AddGatewayCard();
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
        error: (error, stack) => AppErrorState(
          title: 'Error loading gateways',
          message: AppErrorFormatter.format(error),
        ),
      ),
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
