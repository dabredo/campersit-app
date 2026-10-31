import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDeleteButton extends StatelessWidget {
  const AppDeleteButton({
    super.key,
    required this.onTap,
    this.buttonKey,
    this.isLoading = false,
    this.tooltip,
  });

  final VoidCallback onTap;
  final Key? buttonKey;
  final bool isLoading;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.danger,
          ),
        ),
      );
    }

    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: AppRadius.borderXl,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.06),
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: AppColors.danger,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
