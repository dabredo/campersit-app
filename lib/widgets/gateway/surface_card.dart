import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}
