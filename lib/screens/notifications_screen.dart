import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway_notification.dart';
import '../providers/gateway_notification_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/notifications/notification_item_card.dart';
import 'gateway_detail_screen.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastSeenNotificationTimestampProvider.notifier).markAsSeen();
    });

    ref.listen(userNotificationsProvider, (_, _) {
      ref.read(lastSeenNotificationTimestampProvider.notifier).markAsSeen();
    });

    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Notification settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: switch (notificationsAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => _NotificationsErrorView(
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(:final value) => value.isEmpty
            ? const AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications',
                message:
                    'When events occur on your gateways or sensors, they will appear here.',
              )
            : _NotificationsListView(notifications: value),
      },
    );
  }
}

class _NotificationsListView extends StatelessWidget {
  final List<GatewayNotification> notifications;

  const _NotificationsListView({required this.notifications});

  void _onNotificationTap(BuildContext context, GatewayNotification item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GatewayDetailScreen(gatewayId: item.gatewayId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return NotificationItemCard(
          notification: item,
          onTap: () => _onNotificationTap(context, item),
        );
      },
    );
  }
}

class _NotificationsErrorView extends StatelessWidget {
  final String message;

  const _NotificationsErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 36),
            const SizedBox(height: 12),
            Text(
              'Failed to load notifications',
              style: textTheme.titleSmall?.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
