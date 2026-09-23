import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:campersit_app/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService(firebaseAuthInstance: mockFirebaseAuth);
  });

  group('AuthService Tests', () {
    test('signInWithCredentials calls FirebaseAuth correctly on success', () async {
      final mockCredential = MockUserCredential();
      
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@campersit.com',
            password: 'password123',
          )).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithCredentials(
        emailAddress: 'test@campersit.com',
        accountPassword: 'password123',
      );

      expect(result, equals(mockCredential));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@campersit.com',
            password: 'password123',
          )).called(1);
    });

    test('signInWithCredentials throws FirebaseAuthException on failure', () async {
      final exception = FirebaseAuthException(code: 'wrong-password');
      
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@campersit.com',
            password: 'wrong',
          )).thenThrow(exception);

      expect(
        () => authService.signInWithCredentials(
          emailAddress: 'test@campersit.com',
          accountPassword: 'wrong',
        ),
        throwsA(isA<FirebaseAuthException>().having((e) => e.code, 'code', 'wrong-password')),
      );
    });

    test('terminateSession calls FirebaseAuth.signOut', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authService.terminateSession();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
    
    test('currentAuthenticatedUser returns currentUser from FirebaseAuth', () {
      final mockUser = MockUser();
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      final user = authService.currentAuthenticatedUser;
      
      expect(user, equals(mockUser));
    });
  });
}
