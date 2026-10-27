import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/repositories/notification_repository.dart';
import 'package:campersit_app/services/fcm_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  late MockFirebaseMessaging mockMessaging;
  late MockNotificationRepository mockRepository;
  late MockNotificationSettings mockSettings;
  late FcmService service;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    mockRepository = MockNotificationRepository();
    mockSettings = MockNotificationSettings();

    service = FcmService(
      messaging: mockMessaging,
      repository: mockRepository,
    );
  });

  group('FcmService Tests', () {
    test('initializes and saves token when permissions are authorized', () async {
      when(() => mockMessaging.requestPermission(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          )).thenAnswer((_) async => mockSettings);

      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockMessaging.getToken())
          .thenAnswer((_) async => 'mock_fcm_token');
      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => const Stream.empty());

      when(() => mockRepository.saveDeviceToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).thenAnswer((_) async {});

      await service.initialize(userId: 'user_123');

      verify(() => mockRepository.saveDeviceToken(
            userId: 'user_123',
            token: 'mock_fcm_token',
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).called(1);
    });

    test('does not save token when permissions are denied', () async {
      when(() => mockMessaging.requestPermission(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          )).thenAnswer((_) async => mockSettings);

      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.denied);

      await service.initialize(userId: 'user_123');

      verifyNever(() => mockMessaging.getToken());
      verifyNever(() => mockRepository.saveDeviceToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          ));
    });

    test('avoids duplicate initialization for same user', () async {
      when(() => mockMessaging.requestPermission(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          )).thenAnswer((_) async => mockSettings);

      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockMessaging.getToken())
          .thenAnswer((_) async => 'mock_fcm_token');
      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => const Stream.empty());

      when(() => mockRepository.saveDeviceToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).thenAnswer((_) async {});

      await service.initialize(userId: 'user_123');
      await service.initialize(userId: 'user_123');

      verify(() => mockRepository.saveDeviceToken(
            userId: 'user_123',
            token: 'mock_fcm_token',
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).called(1);
    });

    test('initializes with custom vapidKey', () async {
      when(() => mockMessaging.requestPermission(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          )).thenAnswer((_) async => mockSettings);

      when(() => mockSettings.authorizationStatus)
          .thenReturn(AuthorizationStatus.authorized);
      when(() => mockMessaging.getToken(vapidKey: any(named: 'vapidKey')))
          .thenAnswer((_) async => 'mock_vapid_token');
      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => const Stream.empty());

      when(() => mockRepository.saveDeviceToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).thenAnswer((_) async {});

      await service.initialize(
        userId: 'user_vapid',
        vapidKey: 'test_vapid_key',
      );

      verify(() => mockMessaging.getToken(vapidKey: 'test_vapid_key')).called(1);
      verify(() => mockRepository.saveDeviceToken(
            userId: 'user_vapid',
            token: 'mock_vapid_token',
            userAgent: any(named: 'userAgent'),
            userEmail: any(named: 'userEmail'),
          )).called(1);
    });

    test('unregisters token on sign out', () async {
      when(() => mockMessaging.getToken())
          .thenAnswer((_) async => 'mock_fcm_token');
      when(() => mockRepository.removeDeviceToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
          )).thenAnswer((_) async {});

      await service.unregisterToken('user_123');

      verify(() => mockRepository.removeDeviceToken(
            userId: 'user_123',
            token: 'mock_fcm_token',
          )).called(1);
    });
  });
}
