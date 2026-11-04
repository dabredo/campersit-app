import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';

class AppSeenAtText extends StatelessWidget {
  const AppSeenAtText({
    super.key,
    required this.seenAt,
    this.fallbackText = 'Not seen yet',
  });

  final int? seenAt;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final text = switch (seenAt) {
      final timestamp? => formatDateTime(timestamp),
      null => fallbackText,
    };

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontFamily: 'monospace',
        color: AppColors.textSecondary,
      ),
    );
  }
}
