import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDeviceTypeBadge extends StatelessWidget {
  const AppDeviceTypeBadge({
    super.key,
    required this.icon,
    required this.typeLabel,
    this.hasAlerts = false,
  });

  final IconData icon;
  final String typeLabel;
  final bool hasAlerts;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        hasAlerts ? AppColors.danger : AppColors.primaryAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXl,
          ),
          child: Icon(
            icon,
            color: effectiveColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.mainBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            typeLabel.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
