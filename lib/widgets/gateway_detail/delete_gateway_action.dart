import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/gateway_providers.dart';
import '../../theme/app_theme.dart';

class DeleteGatewayAction extends ConsumerWidget {
  const DeleteGatewayAction({super.key, required this.gatewayId});

  final String gatewayId;

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final isConfirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => const _DeleteGatewayDialog(),
        ) ??
        false;
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

class _DeleteGatewayDialog extends StatelessWidget {
  const _DeleteGatewayDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      title: const Text('Delete Gateway'),
      content: const Text('Are you sure you want to delete this gateway?'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
