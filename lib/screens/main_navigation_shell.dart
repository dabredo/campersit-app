import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/common/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'notification_settings_screen.dart';
import 'notifications_screen.dart';

class MainNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final mainNavigationIndexProvider =
    NotifierProvider<MainNavigationNotifier, int>(MainNavigationNotifier.new);

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    NotificationsScreen(),
    NotificationSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
