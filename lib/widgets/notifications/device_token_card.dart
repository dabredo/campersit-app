import 'package:flutter/material.dart';

import '../../models/user_device_token.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';

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
    if (label.contains('ios') || label.contains('iphone') || label.contains('android')) {
      return Icons.phone_android_rounded;
    }
    if (label.contains('mac') || label.contains('windows') || label.contains('linux') || label.contains('pc')) {
      return Icons.laptop_mac_rounded;
    }
    return Icons.devices_other_rounded;
  }

  void _confirmDeletion(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _DeleteTokenConfirmationDialog(
        deviceLabel: token.deviceLabel,
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          onDelete();
        },
      ),
    );
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DeviceIconBadge(icon: _resolveDeviceIcon()),
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
                  token.lastUpdated != null
                      ? 'Active: ${formatDateTime(token.lastUpdated!)}'
                      : 'Active recently',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isDeleting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.danger,
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Delete device token',
              onPressed: () => _confirmDeletion(context),
            ),
        ],
      ),
    );
  }
}

class _DeviceIconBadge extends StatelessWidget {
  final IconData icon;

  const _DeviceIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderXl,
      ),
      child: Icon(
        icon,
        color: AppColors.primaryAccent,
        size: 22,
      ),
    );
  }
}

class _DeleteTokenConfirmationDialog extends StatelessWidget {
  final String deviceLabel;
  final VoidCallback onConfirm;

  const _DeleteTokenConfirmationDialog({
    required this.deviceLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      backgroundColor: AppColors.cardSurface,
      title: Text(
        'Delete Device Token?',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Removing this token will stop push notifications for $deviceLabel until the app or browser is registered again.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Delete',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
