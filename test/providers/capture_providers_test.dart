import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/capture.dart';
import 'package:campersit_app/providers/auth_providers.dart';
import 'package:campersit_app/providers/capture_providers.dart';
import 'package:campersit_app/repositories/capture_repository.dart';

class MockCaptureRepository extends Mock implements CaptureRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockCaptureRepository mockRepository;
  late MockUser mockUser;

  setUp(() {
    mockRepository = MockCaptureRepository();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('user-123');
  });

  group('cameraCapturesProvider', () {
    const testKey = (gatewayId: 'gw-1', sensorId: 'cam-1');

    test('returns empty list when user is null', () async {
      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(mockRepository),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        cameraCapturesProvider(testKey),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final result = await container.read(cameraCapturesProvider(testKey).future);
      expect(result, isEmpty);
      verifyNever(
        () => mockRepository.watchCameraCaptures(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          sensorId: any(named: 'sensorId'),
        ),
      );
    });

    test('streams captures from repository when user is logged in', () async {
      const mockCapture = Capture(
        id: 'cap-1',
        userId: 'user-123',
        deviceId: 'gw-1',
        sensorId: 'cam-1',
        url: 'https://example.com/video.mp4',
        createdAt: 1718000000000,
      );

      when(
        () => mockRepository.watchCameraCaptures(
          userId: 'user-123',
          deviceId: 'gw-1',
          sensorId: 'cam-1',
        ),
      ).thenAnswer((_) => Stream.value([mockCapture]));

      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(mockRepository),
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        cameraCapturesProvider(testKey),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final result = await container.read(cameraCapturesProvider(testKey).future);
      expect(result.length, equals(1));
      expect(result.first.id, equals('cap-1'));
    });
  });
}
