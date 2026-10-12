import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/add_gateway_bottom_sheet.dart';
import '../widgets/gateway_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsyncValue = ref.watch(userGatewaysProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: _buildAppBar(ref),
      body: gatewaysAsyncValue.when(
        data: (gateways) {
          if (gateways.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'You currently have no gateways configured.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: gateways.length,
            itemBuilder: (context, index) {
              return GatewayCard(gateway: gateways[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading gateways:\n$error',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
        onPressed: () => AddGatewayBottomSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref) {
    return AppBar(
      toolbarHeight: 60,
      title: SizedBox(
        height: 60,
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sign out',
          onPressed: () => _handleSignOut(ref),
        ),
      ],
    );
  }

  Future<void> _handleSignOut(WidgetRef ref) async {
    await ref.read(authServiceProvider).terminateSession();
  }
}
