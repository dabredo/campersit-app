import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.observeAuthenticationState();
});

Stream<T> watchAuthenticatedUserStream<T>(
  Ref ref, {
  required T emptyValue,
  required Stream<T> Function(String userId) watch,
}) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(emptyValue);
  }
  return watch(user.uid);
}

final currentUserEmailProvider = Provider<String?>((ref) {
  try {
    return ref.watch(authServiceProvider).currentAuthenticatedUser?.email;
  } catch (_) {
    return null;
  }
});

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithCredentials(
        emailAddress: email,
        accountPassword: password,
      );
    });
  }
}
