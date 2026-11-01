import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SensorTagText extends StatelessWidget {
  const SensorTagText({super.key, required this.tag});

  final String? tag;

  @override
  Widget build(BuildContext context) {
    final currentTag = tag;
    final hasTag = currentTag != null && currentTag.isNotEmpty;

    return Text(
      hasTag ? currentTag : 'Empty tag',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: hasTag
            ? AppColors.primaryAccent
            : AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
