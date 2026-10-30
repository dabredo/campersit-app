import 'package:flutter/material.dart';

import '../../../models/sensor.dart';
import '../../../screens/motion_config_screen.dart';
import '../../../theme/app_theme.dart';

class MotionActionsButton extends StatelessWidget {
  final String gatewayId;
  final Sensor sensor;

  const MotionActionsButton({
    super.key,
    required this.gatewayId,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          backgroundColor: AppColors.cardSurface,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MotionConfigScreen(
                gatewayId: gatewayId,
                sensor: sensor,
              ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Configure Actions',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
