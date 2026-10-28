import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/models/notification_preference.dart';
import 'package:campersit_app/models/user_device_token.dart';
import 'package:campersit_app/providers/auth_providers.dart';
import 'package:campersit_app/providers/gateway_notification_providers.dart';
import 'package:campersit_app/providers/notification_settings_providers.dart';
import 'package:campersit_app/repositories/notification_repository.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockNotificationRepository mockRepository;
  late MockUser mockUser;

  setUp(() {
    mockRepository = MockNotificationRepository();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('user_123');
  });

  group('Notification Settings Providers', () {
    test('userDeviceTokensProvider returns empty list when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userDeviceTokensProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);
      final tokens = await container.read(userDeviceTokensProvider.future);
      expect(tokens, isEmpty);
      verifyNever(() => mockRepository.watchDeviceTokens(any()));
    });

    test('userDeviceTokensProvider watches tokens for authenticated user', () async {
      const sampleToken = UserDeviceToken(
        id: 'token_doc_1',
        fcmToken: 'fcm_1',
      );

      when(() => mockRepository.watchDeviceTokens('user_123'))
          .thenAnswer((_) => Stream.value([sampleToken]));

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userDeviceTokensProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);
      final tokens = await container.read(userDeviceTokensProvider.future);
      expect(tokens.length, equals(1));
      expect(tokens.first.id, equals('token_doc_1'));
      verify(() => mockRepository.watchDeviceTokens('user_123')).called(1);
    });

    test('userNotificationPreferencesProvider returns empty map when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationPreferencesProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);
      final prefs = await container.read(userNotificationPreferencesProvider.future);
      expect(prefs, isEmpty);
      verifyNever(() => mockRepository.watchNotificationPreferences(any()));
    });

    test('userNotificationPreferencesProvider watches preferences for authenticated user', () async {
      const samplePref = NotificationPreference(
        eventType: 'sensor-triggered',
        app: true,
        email: true,
      );

      when(() => mockRepository.watchNotificationPreferences('user_123'))
          .thenAnswer((_) => Stream.value({'sensor-triggered': samplePref}));

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        userNotificationPreferencesProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);
      final prefs = await container.read(userNotificationPreferencesProvider.future);
      expect(prefs.length, equals(1));
      expect(prefs['sensor-triggered']?.app, isTrue);
      expect(prefs['sensor-triggered']?.email, isTrue);
      verify(() => mockRepository.watchNotificationPreferences('user_123')).called(1);
    });

    test('removeToken calls repository removeDeviceTokenById', () async {
      when(() => mockRepository.removeDeviceTokenById(
            userId: 'user_123',
            docId: 'doc_to_delete',
          )).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);

      final controller =
          container.read(notificationSettingsControllerProvider.notifier);
      await controller.removeToken('doc_to_delete');

      verify(() => mockRepository.removeDeviceTokenById(
            userId: 'user_123',
            docId: 'doc_to_delete',
          )).called(1);
    });

    test('toggleAppNotification calls repository updateAppNotificationPreference', () async {
      when(() => mockRepository.updateAppNotificationPreference(
            userId: 'user_123',
            eventType: 'sensor-triggered',
            enabled: true,
          )).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);

      final controller =
          container.read(notificationSettingsControllerProvider.notifier);
      await controller.toggleAppNotification('sensor-triggered', true);

      verify(() => mockRepository.updateAppNotificationPreference(
            userId: 'user_123',
            eventType: 'sensor-triggered',
            enabled: true,
          )).called(1);
    });

    test('toggleEmailNotification calls repository updateEmailNotificationPreference', () async {
      when(() => mockRepository.updateEmailNotificationPreference(
            userId: 'user_123',
            eventType: 'sensor-triggered',
            enabled: false,
          )).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          notificationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(authStateProvider.future);

      final controller =
          container.read(notificationSettingsControllerProvider.notifier);
      await controller.toggleEmailNotification('sensor-triggered', false);

      verify(() => mockRepository.updateEmailNotificationPreference(
            userId: 'user_123',
            eventType: 'sensor-triggered',
            enabled: false,
          )).called(1);
    });
  });
}
