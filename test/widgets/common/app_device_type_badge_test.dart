import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/app_device_type_badge.dart';

void main() {
  group('AppDeviceTypeBadge Widget Tests', () {
    testWidgets('renders icon and uppercase type label with default primary accent color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppDeviceTypeBadge(
              icon: Icons.router_rounded,
              typeLabel: 'Gateway',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.router_rounded), findsOneWidget);
      expect(find.text('GATEWAY'), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.router_rounded));
      expect(iconWidget.color, equals(AppColors.primaryAccent));
      expect(iconWidget.size, equals(24));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final boxConstraints = container.constraints;
      expect(boxConstraints?.maxWidth, equals(44));
      expect(boxConstraints?.maxHeight, equals(44));
    });

    testWidgets('renders danger color when hasAlerts is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppDeviceTypeBadge(
              icon: Icons.air_rounded,
              typeLabel: 'air',
              hasAlerts: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.air_rounded), findsOneWidget);
      expect(find.text('AIR'), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.air_rounded));
      expect(iconWidget.color, equals(AppColors.danger));
    });
  });
}
