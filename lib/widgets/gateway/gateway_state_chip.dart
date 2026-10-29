import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../../theme/app_theme.dart';

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
    final chipColor = gatewayStateColor(state);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.15),
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: chipColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              gatewayStateLabel(state),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: chipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
