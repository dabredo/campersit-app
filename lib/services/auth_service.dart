import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuthInstance})
      : _firebaseAuth = firebaseAuthInstance ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentAuthenticatedUser => _firebaseAuth.currentUser;

  Stream<User?> observeAuthenticationState() => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithCredentials({
    required String emailAddress,
    required String accountPassword,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: emailAddress,
      password: accountPassword,
    );
  }

  Future<void> terminateSession() => _firebaseAuth.signOut();
}
