import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_settings_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/notifications/device_token_card.dart';
import '../widgets/notifications/notification_channel_card.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationSettingsControllerProvider, (_, next) {
      if (next is AsyncError) {
        ref.read(notificationProvider.notifier).showError(
              AppErrorFormatter.format(next.error),
            );
      }
    });

    final tokensAsync = ref.watch(userDeviceTokensProvider);
    final preferencesAsync = ref.watch(userNotificationPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          const _SectionHeader(
            title: 'Delivery Preferences',
            subtitle:
                'Enable or disable app push notifications and email alerts for each event.',
          ),
          const SizedBox(height: 12),
          preferencesAsync.when(
            data: (preferences) => _PreferencesList(preferences: preferences),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primaryAccent),
              ),
            ),
            error: (error, _) => _SettingsErrorCard(
              message: AppErrorFormatter.format(error),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Registered Device Tokens',
            subtitle:
                'Devices currently receiving push notifications. You can delete individual tokens manually at any time.',
          ),
          const SizedBox(height: 12),
          tokensAsync.when(
            data: (tokens) => _DeviceTokensList(tokens: tokens),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primaryAccent),
              ),
            ),
            error: (error, _) => _SettingsErrorCard(
              message: AppErrorFormatter.format(error),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PreferencesList extends ConsumerWidget {
  final Map<String, NotificationPreference> preferences;

  const _PreferencesList({required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (var i = 0; i < NotificationEventDefinition.allEvents.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _PreferenceItem(
            event: NotificationEventDefinition.allEvents[i],
            preference: preferences[NotificationEventDefinition.allEvents[i].type],
          ),
        ],
      ],
    );
  }
}

class _PreferenceItem extends ConsumerWidget {
  final NotificationEventDefinition event;
  final NotificationPreference? preference;

  const _PreferenceItem({
    required this.event,
    required this.preference,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appEnabled = preference?.app ?? false;
    final emailEnabled = preference?.email ?? false;

    return NotificationChannelCard(
      event: event,
      appEnabled: appEnabled,
      emailEnabled: emailEnabled,
      onAppChanged: (enabled) {
        ref
            .read(notificationSettingsControllerProvider.notifier)
            .toggleAppNotification(event.type, enabled);
      },
      onEmailChanged: (enabled) {
        ref
            .read(notificationSettingsControllerProvider.notifier)
            .toggleEmailNotification(event.type, enabled);
      },
    );
  }
}

class _DeviceTokensList extends ConsumerWidget {
  final List<UserDeviceToken> tokens;

  const _DeviceTokensList({required this.tokens});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tokens.isEmpty) {
      return const _EmptyTokensCard();
    }

    return Column(
      children: [
        for (var i = 0; i < tokens.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          DeviceTokenCard(
            token: tokens[i],
            onDelete: () {
              ref
                  .read(notificationSettingsControllerProvider.notifier)
                  .removeToken(tokens[i].id);
            },
          ),
        ],
      ],
    );
  }
}

class _EmptyTokensCard extends StatelessWidget {
  const _EmptyTokensCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderXl,
            ),
            child: const Icon(
              Icons.phonelink_erase_rounded,
              color: AppColors.primaryAccent,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Device Tokens Registered',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Push notification tokens registered from your browsers and devices will appear here.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsErrorCard extends StatelessWidget {
  final String message;

  const _SettingsErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
