import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
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
