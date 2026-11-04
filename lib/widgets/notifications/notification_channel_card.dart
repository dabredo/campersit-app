import 'package:flutter/material.dart';

import '../../models/notification_preference.dart';
import '../../theme/app_theme.dart';
import '../common/app_icon_badge.dart';
import '../common/app_inline_spinner.dart';
import '../common/surface_card.dart';

class NotificationChannelCard extends StatelessWidget {
  final NotificationEventDefinition event;
  final bool appEnabled;
  final bool emailEnabled;
  final ValueChanged<bool> onAppChanged;
  final ValueChanged<bool> onEmailChanged;
  final bool isUpdating;

  const NotificationChannelCard({
    super.key,
    required this.event,
    required this.appEnabled,
    required this.emailEnabled,
    required this.onAppChanged,
    required this.onEmailChanged,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconBadge(icon: event.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUpdating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppInlineSpinner(color: AppColors.primaryAccent),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ChannelToggleRow(
                  icon: Icons.phone_android_rounded,
                  title: 'App',
                  value: appEnabled,
                  onChanged: isUpdating ? null : onAppChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChannelToggleRow(
                  icon: Icons.mail_outline_rounded,
                  title: 'Email',
                  value: emailEnabled,
                  onChanged: isUpdating ? null : onEmailChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ChannelToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: value ? AppColors.primaryAccent : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: value ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryAccent,
            activeTrackColor: AppColors.primaryAccent.withValues(alpha: 0.25),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.borderLight,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
