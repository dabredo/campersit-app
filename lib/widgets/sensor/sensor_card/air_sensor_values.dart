import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AirSensorValues extends StatelessWidget {
  const AirSensorValues({
    super.key,
    this.temperature,
    this.humidity,
  });

  final int? temperature;
  final int? humidity;

  @override
  Widget build(BuildContext context) {
    final temp = temperature;
    final hum = humidity;
    if (temp == null && hum == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          if (temp != null)
            Expanded(
              child: ScalarMetric(
                label: 'Temperature',
                value: '$temp',
                unit: 'ºC',
              ),
            ),
          if (temp != null && hum != null)
            Container(
              height: 28,
              width: 1,
              color: AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
          if (hum != null)
            Expanded(
              child: ScalarMetric(
                label: 'Humidity',
                value: '$hum',
                unit: '%',
              ),
            ),
        ],
      ),
    );
  }
}

class ScalarMetric extends StatelessWidget {
  const ScalarMetric({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData? icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              unit,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
