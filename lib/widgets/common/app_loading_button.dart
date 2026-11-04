import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_inline_spinner.dart';

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

  static const _loadingIndicator =
      AppInlineSpinner(color: AppColors.onAccent, size: 20);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: Center(
        child: isLoading
            ? _loadingIndicator
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon case final leadingIcon?) ...[
                    leadingIcon,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
