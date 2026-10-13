import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import 'app_loading_button.dart';

String _gatewayStateLabel(String state) => switch (state) {
  'c' => 'Connected',
  'i' => 'Inactive',
  'l' => 'Localizing...',
  _ => 'Unknown',
};

String _formatEpochAsDateTime(int epochMilliseconds) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMilliseconds);
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year} $hour:$minute';
}

class GatewayCard extends ConsumerWidget {
  final Gateway gateway;

  const GatewayCard({super.key, required this.gateway});

  Future<void> _deleteGateway(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
        title: const Text(
          'Delete Gateway',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this gateway?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(deleteGatewayControllerProvider(gateway.id).notifier)
          .deleteGateway();
    }
  }

  Future<void> _toggleLocalization(
    WidgetRef ref, {
    required bool isCurrentlyLocalizing,
  }) async {
    await ref
        .read(toggleLocalizationControllerProvider(gateway.id).notifier)
        .toggleLocalization(isCurrentlyLocalizing: isCurrentlyLocalizing);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting =
        ref.watch(deleteGatewayControllerProvider(gateway.id)).isLoading;
    final isTogglingLocalization =
        ref.watch(toggleLocalizationControllerProvider(gateway.id)).isLoading;
    final isLocalizing = gateway.state == 'l';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, isDeleting: isDeleting),
            const SizedBox(height: 8),
            _buildStatusSection(gateway),
            _buildAlertsSection(gateway),
            const SizedBox(height: 16),
            _buildLocationSection(gateway),
            _buildLocationActionButton(
              ref,
              isLocalizing: isLocalizing,
              isLoading: isTogglingLocalization,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref, {
    required bool isDeleting,
  }) {
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
        if (isDeleting)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.redAccent,
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deleteGateway(context, ref),
          ),
      ],
    );
  }

  Widget _buildStatusSection(Gateway gateway) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SecondaryInfoText('State: ${_gatewayStateLabel(gateway.state)}'),
        if (gateway.seenAt != null)
          _SecondaryInfoText('Last seen: ${gateway.seenAt}'),
      ],
    );
  }

  Widget _buildAlertsSection(Gateway gateway) {
    if (gateway.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const _SectionTitle('Alarms:'),
        ...gateway.alerts.entries.map(
          (e) => Text(
            '- ${e.key}: ${e.value}',
            style: const TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(Gateway gateway) {
    if (gateway.location == null) return const SizedBox.shrink();

    final location = gateway.location!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Location:'),
        if (location.exact != null)
          _SecondaryInfoText(
            'Exact: ${location.exact!.latitude}, ${location.exact!.longitude}',
          )
        else if (location.approx != null)
          _SecondaryInfoText(
            'Approx: ${location.approx!.latitude}, ${location.approx!.longitude}',
          ),
        if (location.startedAt != null)
          _SecondaryInfoText(
            'Locating since: ${_formatEpochAsDateTime(location.startedAt!)}',
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationActionButton(
    WidgetRef ref, {
    required bool isLocalizing,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AppLoadingButton(
        isLoading: isLoading,
        onPressed: () =>
            _toggleLocalization(ref, isCurrentlyLocalizing: isLocalizing),
        label: isLocalizing ? 'Stop Localizing' : 'Request Location',
        icon: Icon(isLocalizing ? Icons.stop_circle : Icons.location_on),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocalizing
              ? Colors.orange
              : AppColors.primaryAccent,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SecondaryInfoText extends StatelessWidget {
  const _SecondaryInfoText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
    );
  }
}
