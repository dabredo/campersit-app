import 'package:flutter/material.dart';

import '../../models/notification_preference.dart';
import '../../theme/app_theme.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventIconBadge(icon: event.icon),
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
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 8),
          _ChannelToggleRow(
            icon: Icons.phone_android_rounded,
            title: 'App Push',
            value: appEnabled,
            onChanged: isUpdating ? null : onAppChanged,
          ),
          const SizedBox(height: 4),
          _ChannelToggleRow(
            icon: Icons.mail_outline_rounded,
            title: 'Email Alert',
            value: emailEnabled,
            onChanged: isUpdating ? null : onEmailChanged,
          ),
        ],
      ),
    );
  }
}

class _EventIconBadge extends StatelessWidget {
  final IconData icon;

  const _EventIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderXl,
      ),
      child: Icon(
        icon,
        color: AppColors.primaryAccent,
        size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: value ? AppColors.primaryAccent : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: value ? AppColors.textPrimary : AppColors.textSecondary,
              ),
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
