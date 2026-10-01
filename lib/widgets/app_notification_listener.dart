import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import 'app_notification_bar.dart';

class AppNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState
    extends ConsumerState<AppNotificationListener> {
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _scheduleDismiss(AppNotification notification) {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(notification.duration, () {
      if (mounted) {
        ref.read(notificationProvider.notifier).dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppNotification?>(notificationProvider, (previous, next) {
      if (next != null) {
        _scheduleDismiss(next);
      } else {
        _dismissTimer?.cancel();
      }
    });

    final notification = ref.watch(notificationProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, -1.0),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: notification != null
                ? SafeArea(
                    key: ValueKey(notification.id),
                    child: AppNotificationBar(
                      notification: notification,
                      onDismiss: () =>
                          ref.read(notificationProvider.notifier).dismiss(),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty_notification')),
          ),
        ),
      ],
    );
  }
}
