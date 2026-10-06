import 'package:flutter/material.dart';

class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final ButtonStyle? style;

  static const _loadingIndicator = SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? _loadingIndicator
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );
  }
}
