import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/gateway.dart';
import '../../providers/gateway_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../common/app_loading_button.dart';
import 'delete_gateway_action.dart';
import 'gateway_state_chip.dart';
import '../common/surface_card.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderXl,
                    ),
                    child: const Icon(
                      Icons.router_rounded,
                      color: AppColors.primaryAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'GATEWAY',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gateway Details',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (gateway.seenAt case final seenAt?) ...[
                                const SizedBox(height: 2),
                                Text(
                                  formatDateTime(seenAt),
                                  style: textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GatewayStateChip(state: gateway.state),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              Expanded(child: _ArmGatewayButton(gatewayId: gateway.id)),
              const SizedBox(width: 8),
              Expanded(child: _DisarmGatewayButton(gatewayId: gateway.id)),
              const SizedBox(width: 8),
              DeleteGatewayAction(gatewayId: gateway.id),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _LocalizationButton(gateway: gateway),
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(:key, :value) in alerts.entries)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '- $key: $value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        Text('Location Details', style: Theme.of(context).textTheme.titleSmall),
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

    return AppLoadingButton(
      isLoading: isToggling,
      onPressed: () => ref
          .read(toggleLocalizationControllerProvider(gateway.id).notifier)
          .toggleLocalization(isCurrentlyLocalizing: isLocalizing),
      label: isLocalizing ? 'Stop Localizing' : 'Request Location',
      icon: Icon(
        isLocalizing ? Icons.stop_circle_rounded : Icons.pin_drop_rounded,
        size: 18,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLocalizing
            ? AppColors.warning
            : AppColors.primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  _InfoRow({required this.label, required String value})
    : content = Expanded(child: _InfoRowValue(value));

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

class _ArmGatewayButton extends ConsumerWidget {
  const _ArmGatewayButton({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(armGatewayControllerProvider(gatewayId))
        .isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('arm_gateway_$gatewayId'),
        onTap: isLoading
            ? null
            : () => ref
                  .read(armGatewayControllerProvider(gatewayId).notifier)
                  .armGateway(),
        borderRadius: AppRadius.borderXl,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.armBackground,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: AppColors.armBorder, width: 1),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.armText,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 17,
                      color: AppColors.armText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Arm',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.armText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DisarmGatewayButton extends ConsumerWidget {
  const _DisarmGatewayButton({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(disarmGatewayControllerProvider(gatewayId))
        .isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('disarm_gateway_$gatewayId'),
        onTap: isLoading
            ? null
            : () => ref
                  .read(disarmGatewayControllerProvider(gatewayId).notifier)
                  .disarmGateway(),
        borderRadius: AppRadius.borderXl,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: AppColors.buttonBorder, width: 1),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.disarmText,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_open_rounded,
                      size: 17,
                      color: AppColors.disarmText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Disarm',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.disarmText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
