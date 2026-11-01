import 'package:flutter/material.dart';

import '../../../models/sensor.dart';
import '../../../screens/actuators_screen.dart';
import '../../../theme/app_theme.dart';
import '../../common/app_action_button.dart';

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
    return AppActionButton(
      label: 'Actuators',
      icon: Icons.tune_rounded,
      foregroundColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardSurface,
      borderColor: AppColors.borderLight,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ActuatorsScreen(
              gatewayId: gatewayId,
              sensor: sensor,
            ),
          ),
        );
      },
    );
  }
}
