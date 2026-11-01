import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/gateway_notification_providers.dart';
import '../../screens/main_navigation_shell.dart';
import '../../theme/app_theme.dart';

class BottomNavBar extends ConsumerWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;
  final int? unreadNotificationsCount;

  const BottomNavBar({
    super.key,
    this.currentIndex,
    this.onTap,
    this.unreadNotificationsCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = currentIndex ?? ref.watch(mainNavigationIndexProvider);
    final activeUnreadCount = unreadNotificationsCount ??
        ref.watch(userNotificationsCountProvider) ??
        0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.router_rounded,
                inactiveIcon: Icons.router_outlined,
                label: 'Devices',
                isSelected: activeIndex == 0,
                onTap: () => _handleTap(context, ref, 0),
              ),
              _NavBarItem(
                icon: Icons.notifications_rounded,
                inactiveIcon: Icons.notifications_outlined,
                label: 'Notifications',
                badgeCount: activeUnreadCount,
                isSelected: activeIndex == 1,
                onTap: () => _handleTap(context, ref, 1),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                label: 'Account',
                isSelected: activeIndex == 2,
                onTap: () => _handleTap(context, ref, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    if (index == 1) {
      ref.read(lastSeenNotificationTimestampProvider.notifier).markAsSeen();
    }
    ref.read(mainNavigationIndexProvider.notifier).setIndex(index);

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavBarItem({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primaryAccent;
    final inactiveColor = AppColors.textSecondary;

    Widget iconWidget = Icon(
      isSelected ? icon : inactiveIcon,
      size: 20,
      color: isSelected ? activeColor : inactiveColor,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : '$badgeCount',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.danger,
        offset: const Offset(8, -4),
        child: iconWidget,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mainBackground,
                  borderRadius: AppRadius.border2Xl,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: iconWidget,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: iconWidget,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
