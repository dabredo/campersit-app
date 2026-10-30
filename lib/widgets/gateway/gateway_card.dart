import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/gateway.dart';
import '../../providers/gateway_providers.dart';
import '../../screens/gateway_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import 'delete_gateway_action.dart';
import 'gateway_state_chip.dart';

class GatewayCard extends StatelessWidget {
  final Gateway gateway;

  const GatewayCard({super.key, required this.gateway});

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GatewayDetailScreen(
          gatewayId: gateway.id,
          initialGateway: gateway,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GatewayCardHeader(
                gatewayId: gateway.id,
                state: gateway.state,
                seenAt: gateway.seenAt,
              ),
              _GatewayAlertsSection(alerts: gateway.alerts),
              const SizedBox(height: 12),
              _GatewayActionsRow(gatewayId: gateway.id),
              const SizedBox(height: 12),
              _SensorsSummaryTile(sensorCount: gateway.sensors.length),
              _GatewayLocationSection(gateway: gateway),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayCardHeader extends StatelessWidget {
  final String gatewayId;
  final String state;
  final int? seenAt;

  const _GatewayCardHeader({
    required this.gatewayId,
    required this.state,
    this.seenAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXl,
          ),
          child: const Icon(
            Icons.router_rounded,
            color: AppColors.primaryAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gatewayId,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (seenAt case final timestamp?) ...[
                const SizedBox(height: 2),
                Text(
                  formatDateTime(timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        GatewayStateChip(state: state),
      ],
    );
  }
}

class _GatewayAlertsSection extends StatelessWidget {
  final Map<String, Object?> alerts;

  const _GatewayAlertsSection({required this.alerts});

  static bool _isAlertActive(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    return value != null;
  }

  static String _formatAlertText(String key, Object? value) {
    if (value is bool) return key;
    return '$key: $value';
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.entries
        .where((entry) => _isAlertActive(entry.value))
        .toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final alertTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
          letterSpacing: -0.2,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < activeAlerts.length; i++) ...[
          SizedBox(height: i == 0 ? 10 : 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
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
                  size: 18,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatAlertText(
                      activeAlerts[i].key,
                      activeAlerts[i].value,
                    ),
                    style: alertTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SensorsSummaryTile extends StatelessWidget {
  final int sensorCount;

  const _SensorsSummaryTile({required this.sensorCount});

  @override
  Widget build(BuildContext context) {
    final countLabel =
        '$sensorCount ${sensorCount == 1 ? 'Sensor connected' : 'Sensors connected'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sensors_rounded,
            size: 18,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              countLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _GatewayActionsRow extends StatelessWidget {
  const _GatewayActionsRow({required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ArmGatewayButton(gatewayId: gatewayId)),
        const SizedBox(width: 8),
        Expanded(child: _DisarmGatewayButton(gatewayId: gatewayId)),
        const SizedBox(width: 8),
        DeleteGatewayAction(gatewayId: gatewayId),
      ],
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

class _GatewayLocationSection extends ConsumerWidget {
  const _GatewayLocationSection({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = gateway.location;
    final isLocalizing = gateway.isLocalizing;
    final isToggling = ref
        .watch(toggleLocalizationControllerProvider(gateway.id))
        .isLoading;
    final locationPoint = location?.exact ?? location?.approx;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.armBackground.withValues(alpha: 0.4),
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: AppColors.armText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Location',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                if (!isLocalizing)
                  _RequestLocationButton(
                    gatewayId: gateway.id,
                    isLoading: isToggling,
                  ),
              ],
            ),
            if (isLocalizing) ...[
              const SizedBox(height: 8),
              _LocalizingBanner(
                gatewayId: gateway.id,
                isLoading: isToggling,
              ),
            ],
            if (locationPoint != null) ...[
              const SizedBox(height: 8),
              _LocationCoordinatesTile(
                coordinates: locationPoint.formattedCoordinates,
                startedAt: location?.startedAt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestLocationButton extends ConsumerWidget {
  const _RequestLocationButton({
    required this.gatewayId,
    required this.isLoading,
  });

  final String gatewayId;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('request_location_$gatewayId'),
        onTap: isLoading
            ? null
            : () => ref
                .read(toggleLocalizationControllerProvider(gatewayId).notifier)
                .toggleLocalization(isCurrentlyLocalizing: false),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.armText,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cardSurface,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: AppColors.cardSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Request Location',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.cardSurface,
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

class _LocalizingBanner extends ConsumerWidget {
  const _LocalizingBanner({
    required this.gatewayId,
    required this.isLoading,
  });

  final String gatewayId;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.armBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.armText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Localizing...',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.armText,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('stop_location_$gatewayId'),
              onTap: isLoading
                  ? null
                  : () => ref
                      .read(
                        toggleLocalizationControllerProvider(gatewayId).notifier,
                      )
                      .toggleLocalization(isCurrentlyLocalizing: true),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Stop',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCoordinatesTile extends StatelessWidget {
  const _LocationCoordinatesTile({
    required this.coordinates,
    this.startedAt,
  });

  final String coordinates;
  final int? startedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 16,
            color: AppColors.armText,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              coordinates,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          if (startedAt case final timestamp?)
            Text(
              formatDateTime(timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }
}

