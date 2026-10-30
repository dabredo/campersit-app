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
    if (isDeleted && context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref
        .watch(deleteGatewayControllerProvider(gatewayId))
        .isLoading;

    if (isDeleting) {
      return Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: AppColors.buttonBorder,
            width: 1,
          ),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.danger,
          ),
        ),
      );
    }

    return Tooltip(
      message: 'Delete gateway',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('delete_gateway_$gatewayId'),
          onTap: () => _confirmAndDelete(context, ref),
          borderRadius: AppRadius.borderXl,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: AppColors.buttonBorder,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.danger,
            ),
          ),
        ),
      ),
    );
  }
}

