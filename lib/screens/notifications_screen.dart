import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway_notification.dart';
import '../providers/gateway_notification_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/app_error_state.dart';
import '../widgets/common/section_header.dart';
import '../widgets/notifications/notification_item_card.dart';
import 'gateway_detail_screen.dart';

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

    return CustomScaffold(
      title: 'NOTIFICATIONS',
      showBottomNavBar: false,
      body: switch (notificationsAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => AppErrorState(
            title: 'Failed to load notifications',
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(:final value) =>
          _NotificationsListView(notifications: value),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        const SectionHeader(
          title: 'Activity Notifications',
          subtitle:
              'Recent alerts and event updates from your gateways and sensors.',
        ),
        const SizedBox(height: 16),
        if (notifications.isEmpty)
          const AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No Notifications',
            message:
                'When events occur on your gateways or sensors, they will appear here.',
          )
        else
          for (var i = 0; i < notifications.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            NotificationItemCard(
              notification: notifications[i],
              onTap: () => _onNotificationTap(context, notifications[i]),
            ),
          ],
      ],
    );
  }
}
