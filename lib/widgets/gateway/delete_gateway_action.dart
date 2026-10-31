import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/gateway_providers.dart';
import '../common/app_confirm_dialog.dart';
import '../common/app_delete_button.dart';

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
    if (isDeleted && context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref
        .watch(deleteGatewayControllerProvider(gatewayId))
        .isLoading;

    return AppDeleteButton(
      buttonKey: ValueKey('delete_gateway_$gatewayId'),
      isLoading: isDeleting,
      tooltip: 'Delete gateway',
      onTap: () => _confirmAndDelete(context, ref),
    );
  }
}

