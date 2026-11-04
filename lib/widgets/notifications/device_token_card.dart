import 'package:flutter/material.dart';

import '../../models/user_device_token.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import '../common/app_confirm_dialog.dart';
import '../common/app_delete_button.dart';
import '../common/app_icon_badge.dart';
import '../common/surface_card.dart';

class DeviceTokenCard extends StatelessWidget {
  final UserDeviceToken token;
  final VoidCallback onDelete;
  final bool isDeleting;

  const DeviceTokenCard({
    super.key,
    required this.token,
    required this.onDelete,
    this.isDeleting = false,
  });

  IconData _resolveDeviceIcon() {
    final label = token.deviceLabel.toLowerCase();
    if (label.contains('ios') ||
        label.contains('iphone') ||
        label.contains('android')) {
      return Icons.phone_android_rounded;
    }
    if (label.contains('mac') ||
        label.contains('windows') ||
        label.contains('linux') ||
        label.contains('pc')) {
      return Icons.laptop_mac_rounded;
    }
    return Icons.devices_other_rounded;
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final isConfirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Device Token?',
      content:
          'Removing this token will stop push notifications for ${token.deviceLabel} until the app or browser is registered again.',
    );

    if (isConfirmed) {
      onDelete();
    }
  }

  String _formatTokenPreview(String fcmToken) {
    if (fcmToken.length <= 16) {
      return fcmToken;
    }
    return '${fcmToken.substring(0, 8)}...${fcmToken.substring(fcmToken.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIconBadge(
            icon: _resolveDeviceIcon(),
            dimension: 44,
            iconSize: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.deviceLabel,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTokenPreview(token.fcmToken),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  switch (token.lastUpdated) {
                    final lastUpdated? =>
                      'Active: ${formatDateTime(lastUpdated)}',
                    null => 'Active recently',
                  },
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppDeleteButton(
            isLoading: isDeleting,
            tooltip: 'Delete device token',
            onTap: () => _confirmDeletion(context),
          ),
        ],
      ),
    );
  }
}
