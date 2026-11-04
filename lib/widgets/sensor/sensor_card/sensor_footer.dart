import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

enum _BatteryStatus {
  low,
  medium,
  full;

  // IoT sensors report battery either in millivolts (> 100) or percentage (0-100)
  static const num _mvThreshold = 100;
  static const num _lowMv = 1600;
  static const num _mediumMv = 1800;
  static const num _lowPercent = 20;
  static const num _mediumPercent = 50;

  factory _BatteryStatus.fromLevel(num value) {
    final isMillivolts = value > _mvThreshold;
    if (isMillivolts ? value <= _lowMv : value <= _lowPercent) {
      return _BatteryStatus.low;
    }
    if (isMillivolts ? value <= _mediumMv : value <= _mediumPercent) {
      return _BatteryStatus.medium;
    }
    return _BatteryStatus.full;
  }

  IconData get icon => switch (this) {
    _BatteryStatus.low => Icons.battery_0_bar_rounded,
    _BatteryStatus.medium => Icons.battery_3_bar_rounded,
    _BatteryStatus.full => Icons.battery_full_rounded,
  };

  Color get color => switch (this) {
    _BatteryStatus.low => AppColors.danger,
    _BatteryStatus.medium => AppColors.warning,
    _BatteryStatus.full => AppColors.secondaryAccent,
  };
}

class SensorBatteryIndicator extends StatelessWidget {
  const SensorBatteryIndicator({super.key, required this.battery});

  final num battery;

  @override
  Widget build(BuildContext context) {
    final status = _BatteryStatus.fromLevel(battery);
    final textStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontWeight: FontWeight.w600, color: status.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 13, color: status.color),
        const SizedBox(width: 2),
        Text('${battery.toInt()}', style: textStyle),
        Text(
          '%',
          style: textStyle?.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
