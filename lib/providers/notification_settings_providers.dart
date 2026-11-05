import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import 'auth_providers.dart';
import 'gateway_notification_providers.dart';

final userDeviceTokensProvider =
    StreamProvider<List<UserDeviceToken>>((ref) {
  return watchAuthenticatedUserStream(
    ref,
    emptyValue: const [],
    watch: ref.watch(notificationRepositoryProvider).watchDeviceTokens,
  );
});

final userNotificationPreferencesProvider =
    StreamProvider<Map<String, NotificationPreference>>((ref) {
  return watchAuthenticatedUserStream(
    ref,
    emptyValue: const {},
    watch:
        ref.watch(notificationRepositoryProvider).watchNotificationPreferences,
  );
});

final notificationSettingsControllerProvider =
    AsyncNotifierProvider.autoDispose<NotificationSettingsController, void>(
  NotificationSettingsController.new,
);

class NotificationSettingsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> _runWithUserId(Future<void> Function(String userId) action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(authStateProvider).value?.uid;
      if (userId == null) return;
      await action(userId);
    });
  }

  Future<void> removeToken(String docId) => _runWithUserId(
        (userId) => ref.read(notificationRepositoryProvider).removeDeviceTokenById(
              userId: userId,
              docId: docId,
            ),
      );

  Future<void> toggleAppNotification(String eventType, bool enabled) =>
      _runWithUserId(
        (userId) => ref
            .read(notificationRepositoryProvider)
            .updateAppNotificationPreference(
              userId: userId,
              eventType: eventType,
              enabled: enabled,
            ),
      );

  Future<void> toggleEmailNotification(String eventType, bool enabled) =>
      _runWithUserId(
        (userId) => ref
            .read(notificationRepositoryProvider)
            .updateEmailNotificationPreference(
              userId: userId,
              eventType: eventType,
              enabled: enabled,
            ),
      );
}
