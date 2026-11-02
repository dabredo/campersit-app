import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import '../providers/auth_providers.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_settings_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/section_header.dart';
import '../widgets/notifications/device_token_card.dart';
import '../widgets/notifications/notification_channel_card.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

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

    return CustomScaffold(
      title: 'ACCOUNT',
      showBottomNavBar: false,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _CollapsibleSection(
            title: 'Delivery Preferences',
            subtitle:
                'Enable or disable app push notifications and email alerts for each event.',
            child: switch (preferencesAsync) {
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
          ),
          const SizedBox(height: 14),
          _CollapsibleSection(
            title: 'Registered Device Tokens',
            subtitle:
                'Devices currently receiving push notifications. You can delete individual tokens manually at any time.',
            child: switch (tokensAsync) {
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
          ),
          const SizedBox(height: 16),
          const _AccountSessionSection(),
        ],
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _isExpanded = false;

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.cardSurface,
          borderRadius: AppRadius.border2Xl,
          child: InkWell(
            onTap: _toggle,
            borderRadius: AppRadius.border2Xl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: AppRadius.border2Xl,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SectionHeader(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          widget.child,
        ],
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
        message:
            'Push notification tokens registered from your browsers and devices will appear here.',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
