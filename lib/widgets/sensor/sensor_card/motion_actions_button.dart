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
      height: 32,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: BorderSide(
            color: AppColors.primaryAccent.withValues(alpha: 0.35),
            width: 1,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.06),
        ),
        icon: const Icon(Icons.bolt_rounded, size: 16),
        label: const Text('Configure Actions'),
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
      ),
    );
  }
}
