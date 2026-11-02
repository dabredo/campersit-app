import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/theme/app_theme.dart';
import 'package:campersit_app/widgets/common/section_header.dart';

void main() {
  group('SectionHeader Widget Tests', () {
    testWidgets('renders title and subtitle with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Actuators for Door Sensor',
              subtitle: 'These actuators trigger on motion.',
            ),
          ),
        ),
      );

      expect(find.text('Actuators for Door Sensor'), findsOneWidget);
      expect(find.text('These actuators trigger on motion.'), findsOneWidget);

      final titleWidget = tester.widget<Text>(find.text('Actuators for Door Sensor'));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.w700));
      expect(titleWidget.style?.color, equals(AppColors.textPrimary));

      final subtitleWidget = tester.widget<Text>(find.text('These actuators trigger on motion.'));
      expect(subtitleWidget.style?.color, equals(AppColors.textSecondary));
    });

    testWidgets('omits subtitle when not provided or empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Only Title',
            ),
          ),
        ),
      );

      expect(find.text('Only Title'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Padded Header',
              padding: EdgeInsets.all(20),
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      expect(paddingWidget.padding, equals(const EdgeInsets.all(20)));
    });
  });
}
