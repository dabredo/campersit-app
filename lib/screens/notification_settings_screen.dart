import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import '../providers/auth_providers.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_settings_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/notifications/device_token_card.dart';
import '../widgets/notifications/notification_channel_card.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationSettingsControllerProvider, (_, next) {
      if (next is AsyncError) {
        ref
            .read(notificationProvider.notifier)
            .showError(AppErrorFormatter.format(next.error));
      }
    });

    final tokensAsync = ref.watch(userDeviceTokensProvider);
    final preferencesAsync = ref.watch(userNotificationPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: const AppAppBar(title: 'Notification Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          const _SectionHeader(
            title: 'Delivery Preferences',
            subtitle: 'Enable or disable app push notifications and email alerts for each event.',
          ),
          const SizedBox(height: 12),
          switch (preferencesAsync) {
            AsyncData(:final value) => _PreferencesList(preferences: value),
            AsyncLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.primaryAccent,
                ),
              ),
            ),
            AsyncError(:final error) => AppErrorState(
              title: 'Failed to load preferences',
              message: AppErrorFormatter.format(error),
            ),
          },
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Registered Device Tokens',
            subtitle:
                'Devices currently receiving push notifications. You can delete individual tokens manually at any time.',
          ),
          const SizedBox(height: 12),
          switch (tokensAsync) {
            AsyncData(:final value) => _DeviceTokensList(tokens: value),
            AsyncLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.primaryAccent,
                ),
              ),
            ),
            AsyncError(:final error) => AppErrorState(
              title: 'Failed to load device tokens',
              message: AppErrorFormatter.format(error),
            ),
          },
          const SizedBox(height: 16),
          const _AccountSessionSection(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

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
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        for (
          var i = 0;
          i < NotificationEventDefinition.allEvents.length;
          i++
        ) ...[
          if (i > 0) const SizedBox(height: 10),
          _PreferenceItem(
            event: NotificationEventDefinition.allEvents[i],
            preference:
                preferences[NotificationEventDefinition.allEvents[i].type],
          ),
        ],
      ],
    );
  }
}

class _PreferenceItem extends ConsumerWidget {
  final NotificationEventDefinition event;
  final NotificationPreference? preference;

  const _PreferenceItem({required this.event, required this.preference});

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
      return const AppEmptyState(
        icon: Icons.phonelink_erase_rounded,
        title: 'No Device Tokens Registered',
        message: 'Push notification tokens registered from your browsers and devices will appear here.',
      );
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

class _AccountSessionSection extends ConsumerWidget {
  const _AccountSessionSection();

  Future<void> _handleSignOut(WidgetRef ref) async {
    await ref.read(authServiceProvider).terminateSession();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(currentUserEmailProvider);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          Material(
            color: AppColors.cardSurface,
            borderRadius: AppRadius.border2Xl,
            child: InkWell(
              onTap: () => _handleSignOut(ref),
              borderRadius: AppRadius.border2Xl,
              splashColor: AppColors.danger.withValues(alpha: 0.08),
              highlightColor: AppColors.danger.withValues(alpha: 0.04),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.border2Xl,
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (userEmail != null && userEmail.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Signed in as ',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: userEmail,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
