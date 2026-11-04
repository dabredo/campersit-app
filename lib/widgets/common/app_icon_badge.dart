import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.primaryAccent,
    this.dimension = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color color;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderXl,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

