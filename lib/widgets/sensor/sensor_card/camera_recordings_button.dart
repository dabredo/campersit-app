import 'package:flutter/material.dart';

import '../../../models/sensor.dart';
import '../../../screens/camera_captures_screen.dart';
import '../../../theme/app_theme.dart';
import '../../common/app_action_button.dart';

class CameraRecordingsButton extends StatelessWidget {
  final String gatewayId;
  final Sensor sensor;

  const CameraRecordingsButton({
    super.key,
    required this.gatewayId,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionButton(
      label: 'Recordings',
      icon: Icons.video_library_rounded,
      foregroundColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardSurface,
      borderColor: AppColors.borderLight,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CameraCapturesScreen(
              gatewayId: gatewayId,
              sensor: sensor,
            ),
          ),
        );
      },
    );
  }
}
