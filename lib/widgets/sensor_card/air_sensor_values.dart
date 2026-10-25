import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (temp != null)
            ScalarMetric(
              icon: Icons.thermostat_rounded,
              label: 'Temperature',
              value: '$temp',
              unit: 'ºC',
            ),
          if (temp != null && hum != null)
            Container(
              height: 24,
              width: 1,
              color: AppColors.borderLight,
            ),
          if (hum != null)
            ScalarMetric(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '$hum',
              unit: '%',
            ),
        ],
      ),
    );
  }
}

class ScalarMetric extends StatelessWidget {
  const ScalarMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryAccent),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
