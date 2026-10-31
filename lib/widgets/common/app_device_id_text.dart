import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDeviceIdText extends StatelessWidget {
  const AppDeviceIdText({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Text(
      deviceId,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
