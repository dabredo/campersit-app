import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

final applicationAuthenticationService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (initializationError) {
    debugPrint('Firebase initialization warning: $initializationError');
  }
  runApp(const CampersitApplication());
}

class CampersitApplication extends StatelessWidget {
  const CampersitApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campersit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: applicationAuthenticationService.observeAuthenticationState(),
        builder: (context, authenticationSnapshot) {
          final isWaitingForConnection =
              authenticationSnapshot.connectionState == ConnectionState.waiting;
          if (isWaitingForConnection) {
            return const Scaffold(
              backgroundColor: AppColors.mainBackground,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryAccent,
                ),
              ),
            );
          }

          final isAuthenticated =
              authenticationSnapshot.hasData && authenticationSnapshot.data != null;
          if (isAuthenticated) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
