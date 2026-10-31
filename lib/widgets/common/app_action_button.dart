import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final effectiveForeground = foregroundColor ?? AppColors.textPrimary;
    final effectiveBackground = backgroundColor ?? AppColors.cardSurface;
    final effectiveBorder = borderColor ?? AppColors.borderLight;
    final isInteractive = !isLoading && onPressed != null;

    return SizedBox(
      height: 38,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveForeground,
          backgroundColor: effectiveBackground,
          side: BorderSide(color: effectiveBorder, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
          ),
          padding: padding,
          elevation: 0,
        ),
        onPressed: isInteractive ? onPressed : null,
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveForeground),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: effectiveForeground,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: effectiveForeground,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
