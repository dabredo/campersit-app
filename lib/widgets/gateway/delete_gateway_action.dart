import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/gateway_providers.dart';
import '../../theme/app_theme.dart';

import '../common/app_confirm_dialog.dart';

class DeleteGatewayAction extends ConsumerWidget {
  const DeleteGatewayAction({super.key, required this.gatewayId});

  final String gatewayId;

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Gateway',
      content: 'Are you sure you want to delete this gateway?',
    );
    if (!isConfirmed || !context.mounted) return;

    final isDeleted = await ref
        .read(deleteGatewayControllerProvider(gatewayId).notifier)
        .deleteGateway();
    if (isDeleted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref
        .watch(deleteGatewayControllerProvider(gatewayId))
        .isLoading;

    if (isDeleting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.danger,
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
      tooltip: 'Delete gateway',
      onPressed: () => _confirmAndDelete(context, ref),
    );
  }
}

