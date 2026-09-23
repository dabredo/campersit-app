import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_providers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (initializationError) {
    debugPrint('Firebase initialization warning: $initializationError');
  }
  runApp(
    const ProviderScope(
      child: CampersitApplication(),
    ),
  );
}

class CampersitApplication extends ConsumerWidget {
  const CampersitApplication({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Campersit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.mainBackground,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryAccent,
            ),
          ),
        ),
        error: (error, stack) => const Scaffold(
          backgroundColor: AppColors.mainBackground,
          body: Center(
            child: Text('Authentication error.'),
          ),
        ),
      ),
    );
  }
}
