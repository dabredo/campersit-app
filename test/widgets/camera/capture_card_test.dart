import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/capture.dart';
import 'package:campersit_app/providers/capture_providers.dart';
import 'package:campersit_app/repositories/capture_repository.dart';
import 'package:campersit_app/widgets/camera/capture_card.dart';

class MockCaptureRepository extends Mock implements CaptureRepository {}

void main() {
  late MockCaptureRepository mockCaptureRepository;

  setUp(() {
    mockCaptureRepository = MockCaptureRepository();
  });

  testWidgets('CaptureCard displays capture info and confirms deletion', (
    tester,
  ) async {
    when(
      () => mockCaptureRepository.deleteCapture('CAP-1'),
    ).thenAnswer((_) async {});

    final capture = Capture(
      id: 'CAP-1',
      userId: 'user-1',
      deviceId: 'GW-1',
      sensorId: 'CAM-1',
      url: 'https://example.com/video.mp4',
      createdAt: DateTime(2026, 10, 18, 12, 0).millisecondsSinceEpoch,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          captureRepositoryProvider.overrideWithValue(mockCaptureRepository),
        ],
        child: MaterialApp(
          home: Scaffold(body: CaptureCard(capture: capture)),
        ),
      ),
    );

    expect(find.text('ID: CAP-1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('delete_capture_CAP-1')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Capture'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => mockCaptureRepository.deleteCapture('CAP-1')).called(1);
  });
}
