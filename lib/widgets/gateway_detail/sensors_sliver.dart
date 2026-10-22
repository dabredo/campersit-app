import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../theme/app_theme.dart';
import '../sensor_card.dart';
import 'surface_card.dart';

class SensorsSliver extends StatelessWidget {
  const SensorsSliver({super.key, required this.gatewayId, required this.sensors});

  static const double _wideLayoutBreakpoint = 500;
  static const double _sensorSpacing = 12;

  final String gatewayId;
  final List<Sensor> sensors;

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptySensorsPlaceholder());
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen =
            constraints.crossAxisExtent >= _wideLayoutBreakpoint;

        if (isWideScreen) {
          final rowCount = (sensors.length + 1) ~/ 2;
          return SliverList.separated(
            itemCount: rowCount,
            separatorBuilder: (_, _) => const SizedBox(height: _sensorSpacing),
            itemBuilder: (_, rowIndex) {
              final firstIndex = rowIndex * 2;
              final secondIndex = firstIndex + 1;
              return _SensorGridRow(
                firstSensor: sensors[firstIndex],
                secondSensor:
                    secondIndex < sensors.length ? sensors[secondIndex] : null,
                gatewayId: gatewayId,
                spacing: _sensorSpacing,
              );
            },
          );
        }

        return SliverList.separated(
          itemCount: sensors.length,
          separatorBuilder: (_, _) => const SizedBox(height: _sensorSpacing),
          itemBuilder: (_, index) =>
              SensorCard(sensor: sensors[index], gatewayId: gatewayId),
        );
      },
    );
  }
}

class _SensorGridRow extends StatelessWidget {
  const _SensorGridRow({
    required this.firstSensor,
    required this.secondSensor,
    required this.gatewayId,
    required this.spacing,
  });

  final Sensor firstSensor;
  final Sensor? secondSensor;
  final String gatewayId;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final second = secondSensor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SensorCard(sensor: firstSensor, gatewayId: gatewayId),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: second != null
              ? SensorCard(sensor: second, gatewayId: gatewayId)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class SensorsSectionHeader extends StatelessWidget {
  const SensorsSectionHeader({super.key, required this.sensorCount});

  final int sensorCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Icon(
          Icons.sensors_rounded,
          color: AppColors.primaryAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Sensors',
          style: textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXl,
          ),
          child: Text(
            '$sensorCount',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySensorsPlaceholder extends StatelessWidget {
  const _EmptySensorsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off_rounded,
            size: 44,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No Sensors Configured',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'There are no telemetry sensors associated with this gateway yet.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
