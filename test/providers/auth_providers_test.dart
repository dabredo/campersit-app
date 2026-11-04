import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/providers/auth_providers.dart';
import 'package:campersit_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('auth_providers', () {
    test('authStateProvider emits user from AuthService stream', () async {
      final mockUser = MockUser();
      when(
        () => mockAuthService.observeAuthenticationState(),
      ).thenAnswer((_) => Stream.value(mockUser));

      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);
      await pumpEventQueue();

      expect(container.read(authStateProvider).value, same(mockUser));
    });

    test('currentUserEmailProvider returns current user email or null on error', () {
      final mockUser = MockUser();
      when(() => mockUser.email).thenReturn('camper@campersit.com');
      when(() => mockAuthService.currentAuthenticatedUser).thenReturn(mockUser);

      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(currentUserEmailProvider),
        equals('camper@campersit.com'),
      );
    });

    test('LoginController calls signInWithCredentials and sets error on failure', () async {
      when(
        () => mockAuthService.signInWithCredentials(
          emailAddress: 'user@campersit.com',
          accountPassword: 'secret',
        ),
      ).thenAnswer((_) async => MockUserCredential());

      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
      addTearDown(container.dispose);

      await container
          .read(loginControllerProvider.notifier)
          .login('user@campersit.com', 'secret');

      expect(container.read(loginControllerProvider).hasError, isFalse);
      verify(
        () => mockAuthService.signInWithCredentials(
          emailAddress: 'user@campersit.com',
          accountPassword: 'secret',
        ),
      ).called(1);
    });
  });
}
