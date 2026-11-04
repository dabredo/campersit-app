import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/gateway.dart';
import '../../providers/gateway_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../common/app_inline_spinner.dart';

class GatewayLocationSection extends ConsumerWidget {
  const GatewayLocationSection({super.key, required this.gateway});

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
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
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
                        color: AppColors.secondaryAccent.withValues(
                          alpha: 0.15,
                        ),
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
              _LocalizingBanner(gatewayId: gateway.id, isLoading: isToggling),
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
                  .read(
                    toggleLocalizationControllerProvider(gatewayId).notifier,
                  )
                  .toggleLocalization(isCurrentlyLocalizing: false),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.armText,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? const AppInlineSpinner(color: AppColors.cardSurface, size: 12)
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
  const _LocalizingBanner({required this.gatewayId, required this.isLoading});

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
                          toggleLocalizationControllerProvider(gatewayId)
                              .notifier,
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
  const _LocationCoordinatesTile({required this.coordinates, this.startedAt});

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
