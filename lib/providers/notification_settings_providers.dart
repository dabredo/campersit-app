import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import 'auth_providers.dart';
import 'gateway_notification_providers.dart';

final userDeviceTokensProvider =
    StreamProvider<List<UserDeviceToken>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.value;
  if (user == null) {
    if (authAsync.isLoading) {
      return const Stream.empty();
    }
    return Stream.value(const []);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchDeviceTokens(user.uid);
});

final userNotificationPreferencesProvider =
    StreamProvider<Map<String, NotificationPreference>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.value;
  if (user == null) {
    if (authAsync.isLoading) {
      return const Stream.empty();
    }
    return Stream.value(const {});
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchNotificationPreferences(user.uid);
});

final notificationSettingsControllerProvider =
    AsyncNotifierProvider.autoDispose<NotificationSettingsController, void>(
  NotificationSettingsController.new,
);

class NotificationSettingsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> removeToken(String docId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value ??
          ref.read(authServiceProvider).currentAuthenticatedUser;
      if (user == null) return;

      await ref.read(notificationRepositoryProvider).removeDeviceTokenById(
            userId: user.uid,
            docId: docId,
          );
    });
  }

  Future<void> updatePreference(
    String eventType,
    NotificationDeliveryChannel channel,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value ??
          ref.read(authServiceProvider).currentAuthenticatedUser;
      if (user == null) return;

      await ref
          .read(notificationRepositoryProvider)
          .updateNotificationPreference(
            userId: user.uid,
            eventType: eventType,
            app: channel.includesApp,
            email: channel.includesEmail,
          );
    });
  }
}
