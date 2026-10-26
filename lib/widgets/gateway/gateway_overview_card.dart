import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/gateway.dart';
import '../../providers/gateway_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../common/app_loading_button.dart';
import 'gateway_state_chip.dart';
import 'surface_card.dart';

class GatewayOverviewCard extends StatelessWidget {
  const GatewayOverviewCard({super.key, required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gateway Details',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _InfoRow.custom(
            label: 'State',
            trailing: GatewayStateChip(state: gateway.state),
          ),
          if (gateway.seenAt case final seenAt?) ...[
            const SizedBox(height: 6),
            _InfoRow(label: 'Last seen', value: formatDateTime(seenAt)),
          ],
          if (gateway.alerts.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AlarmsList(alerts: gateway.alerts),
          ],
          if (gateway.location case final location?) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 12),
            _LocationDetails(location: location),
          ],
          const SizedBox(height: 16),
          _LocalizationButton(gateway: gateway),
        ],
      ),
    );
  }
}

class _AlarmsList extends StatelessWidget {
  const _AlarmsList({required this.alerts});

  final Map<String, Object?> alerts;

  @override
  Widget build(BuildContext context) {
    final alarmStyle = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AppColors.danger);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alarms:',
          style: alarmStyle?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        for (final MapEntry(:key, :value) in alerts.entries)
          Text('- $key: $value', style: alarmStyle),
      ],
    );
  }
}

class _LocationDetails extends StatelessWidget {
  const _LocationDetails({required this.location});

  final GatewayLocation location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        if (location.exact case final exactPoint?)
          _InfoRow(label: 'Exact', value: exactPoint.formattedCoordinates)
        else if (location.approx case final approxPoint?)
          _InfoRow(label: 'Approx', value: approxPoint.formattedCoordinates),
        if (location.startedAt case final startedAt?) ...[
          const SizedBox(height: 4),
          _InfoRow(label: 'Locating since', value: formatDateTime(startedAt)),
        ],
      ],
    );
  }
}

class _LocalizationButton extends ConsumerWidget {
  const _LocalizationButton({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocalizing = gateway.isLocalizing;
    final isToggling = ref
        .watch(toggleLocalizationControllerProvider(gateway.id))
        .isLoading;

    return SizedBox(
      width: double.infinity,
      child: AppLoadingButton(
        isLoading: isToggling,
        onPressed: () => ref
            .read(toggleLocalizationControllerProvider(gateway.id).notifier)
            .toggleLocalization(isCurrentlyLocalizing: isLocalizing),
        label: isLocalizing ? 'Stop Localizing' : 'Request Location',
        icon: Icon(isLocalizing ? Icons.stop_circle : Icons.location_on),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocalizing
              ? AppColors.warning
              : AppColors.primaryAccent,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  _InfoRow({required this.label, required String value})
    : content = Expanded(child: _InfoRowValue(value));

  const _InfoRow.custom({required this.label, required Widget trailing})
    : content = trailing;

  static const double _labelColumnWidth = 95;

  final String label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelColumnWidth,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        content,
      ],
    );
  }
}

class _InfoRowValue extends StatelessWidget {
  const _InfoRowValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    );
  }
}
