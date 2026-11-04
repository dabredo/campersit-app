import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_icon_badge.dart';

void main() {
  testWidgets('AppIconBadge renders icon with configured dimension and color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppIconBadge(
            icon: Icons.notifications_rounded,
            color: AppColors.danger,
            dimension: 44,
            iconSize: 22,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, equals(Icons.notifications_rounded));
    expect(icon.color, equals(AppColors.danger));
    expect(icon.size, equals(22));
  });
}

