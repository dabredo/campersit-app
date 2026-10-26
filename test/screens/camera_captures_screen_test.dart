import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/capture.dart';
import 'package:campersit_app/models/sensor.dart';
import 'package:campersit_app/providers/capture_providers.dart';
import 'package:campersit_app/repositories/capture_repository.dart';
import 'package:campersit_app/screens/camera_captures_screen.dart';
import 'package:campersit_app/widgets/camera/capture_card.dart';

class MockCaptureRepository extends Mock implements CaptureRepository {}

void main() {
  group('CameraCapturesScreen', () {
    const testGatewayId = 'gw-1';
    const testSensor = Sensor(
      id: 'cam-01',
      type: SensorType.camera,
      state: SensorState.enabled,
      tag: 'Living Room Camera',
    );
    const testKey = (gatewayId: testGatewayId, sensorId: 'cam-01');

    Widget createWidget({required List overrides}) {
      return ProviderScope(
        overrides: overrides.cast(),
        child: const MaterialApp(
          home: CameraCapturesScreen(
            gatewayId: testGatewayId,
            sensor: testSensor,
          ),
        ),
      );
    }

    testWidgets('renders loading spinner when AsyncLoading', (tester) async {
      await tester.pumpWidget(
        createWidget(
          overrides: [
            cameraCapturesProvider(testKey).overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
        ),
      );

      expect(find.text('Living Room Camera Recordings'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no recordings exist', (tester) async {
      await tester.pumpWidget(
        createWidget(
          overrides: [
            cameraCapturesProvider(testKey).overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('No Recordings Found'), findsOneWidget);
      expect(
        find.text(
          'Recorded videos will be listed here when captures are available.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders error state when provider emits error', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          overrides: [
            cameraCapturesProvider(testKey).overrideWith(
              (ref) => Stream.error(Exception('Firestore network error')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error loading recordings'), findsOneWidget);
      expect(
        find.text('An unexpected error occurred. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('renders list of captures when data is emitted', (
      tester,
    ) async {
      const capture1 = Capture(
        id: 'cap-101',
        userId: 'user-1',
        deviceId: testGatewayId,
        sensorId: 'cam-01',
        url: 'https://example.com/video1.mp4',
        createdAt: 1718000000000,
      );
      const capture2 = Capture(
        id: 'cap-102',
        userId: 'user-1',
        deviceId: testGatewayId,
        sensorId: 'cam-01',
        url: 'https://example.com/video2.mp4',
        createdAt: 1718001000000,
      );

      await tester.pumpWidget(
        createWidget(
          overrides: [
            cameraCapturesProvider(testKey).overrideWith(
              (ref) => Stream.value([capture2, capture1]),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CaptureCard), findsNWidgets(2));
      expect(find.text('ID: cap-101'), findsOneWidget);
      expect(find.text('ID: cap-102'), findsOneWidget);
    });

    testWidgets('confirms and calls deleteCapture on capture card', (
      tester,
    ) async {
      final mockRepository = MockCaptureRepository();
      when(() => mockRepository.deleteCapture('cap-101'))
          .thenAnswer((_) async {});

      const capture1 = Capture(
        id: 'cap-101',
        userId: 'user-1',
        deviceId: testGatewayId,
        sensorId: 'cam-01',
        url: 'https://example.com/video1.mp4',
        createdAt: 1718000000000,
      );

      await tester.pumpWidget(
        createWidget(
          overrides: [
            captureRepositoryProvider.overrideWithValue(mockRepository),
            cameraCapturesProvider(testKey).overrideWith(
              (ref) => Stream.value([capture1]),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('delete_capture_cap-101')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('delete_capture_cap-101')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Capture'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this recording (cap-101)? This action cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.deleteCapture('cap-101')).called(1);
    });
  });
}

