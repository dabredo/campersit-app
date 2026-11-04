import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_provider.dart';

abstract class AsyncActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> runNotifiedAction(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(action);

      final error = state.error;
      if (error != null) {
        ref.read(notificationProvider.notifier).showError(error);
        return false;
      }

      if (successMessage != null) {
        ref.read(notificationProvider.notifier).showSuccess(successMessage);
      }
      return true;
    } finally {
      link.close();
    }
  }
}

