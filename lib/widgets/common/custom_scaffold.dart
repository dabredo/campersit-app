import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_bar.dart';
import 'bottom_nav_bar.dart';

class CustomScaffold extends StatelessWidget {
  final String? title;
  final PreferredSizeWidget? appBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget body;
  final bool showBottomNavBar;
  final Widget? floatingActionButton;

  const CustomScaffold({
    super.key,
    this.title,
    this.appBar,
    this.showBackButton = false,
    this.onBackPressed,
    required this.body,
    this.showBottomNavBar = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget? effectiveAppBar = appBar ??
        (title != null
            ? AppAppBar(
                title: title!,
                showBackButton: showBackButton,
                onBackPressed: onBackPressed,
              )
            : null);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: effectiveAppBar,
      body: body,
      bottomNavigationBar: showBottomNavBar ? const BottomNavBar() : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
