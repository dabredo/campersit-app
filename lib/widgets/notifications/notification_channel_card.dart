import 'package:flutter/material.dart';

import '../../models/notification_preference.dart';
import '../../theme/app_theme.dart';

class NotificationChannelCard extends StatelessWidget {
  final NotificationEventDefinition event;
  final NotificationDeliveryChannel channel;
  final ValueChanged<NotificationDeliveryChannel> onChannelChanged;
  final bool isUpdating;

  const NotificationChannelCard({
    super.key,
    required this.event,
    required this.channel,
    required this.onChannelChanged,
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
          _ChannelSegmentedControl(
            currentChannel: channel,
            onChanged: isUpdating ? null : onChannelChanged,
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

class _ChannelSegmentedControl extends StatelessWidget {
  final NotificationDeliveryChannel currentChannel;
  final ValueChanged<NotificationDeliveryChannel>? onChanged;

  const _ChannelSegmentedControl({
    required this.currentChannel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<NotificationDeliveryChannel>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.borderLight),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryAccent;
            }
            return AppColors.mainBackground;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppColors.textSecondary;
          }),
          textStyle: WidgetStateProperty.all(
            textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        segments: const [
          ButtonSegment(
            value: NotificationDeliveryChannel.none,
            label: Text('None'),
          ),
          ButtonSegment(
            value: NotificationDeliveryChannel.app,
            label: Text('App Push'),
          ),
          ButtonSegment(
            value: NotificationDeliveryChannel.email,
            label: Text('Email'),
          ),
          ButtonSegment(
            value: NotificationDeliveryChannel.both,
            label: Text('Both'),
          ),
        ],
        selected: {currentChannel},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) {
                if (selection.isNotEmpty) {
                  onChanged!(selection.first);
                }
              },
      ),
    );
  }
}
