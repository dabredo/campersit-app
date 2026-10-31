import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../theme/app_theme.dart';
import '../common/app_state_chip.dart';

Color gatewayStateColor(String state) => switch (state) {
  GatewayStates.connected => AppColors.secondaryAccent,
  GatewayStates.localizing => AppColors.warning,
  GatewayStates.initialized => AppColors.textSecondary,
  GatewayStates.unpaired => AppColors.textSecondary,
  _ => AppColors.textSecondary,
};

class GatewayStateChip extends StatelessWidget {
  final String state;

  const GatewayStateChip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppStateChip(
      label: gatewayStateLabel(state),
      color: gatewayStateColor(state),
    );
  }
}
