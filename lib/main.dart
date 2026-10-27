import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_providers.dart';
import 'providers/gateway_notification_providers.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'widgets/common/app_notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Background message isolate handler is unsupported on Flutter Web
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
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

  void _initializeFcm(WidgetRef ref, String userId, String? userEmail) {
    ref.read(fcmServiceProvider).initialize(
          userId: userId,
          userEmail: userEmail,
          onForegroundMessage: (title, body) {
            final message = body.trim().isNotEmpty ? '$title: $body' : title;
            ref.read(notificationProvider.notifier).showInfo(message);
          },
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _initializeFcm(ref, user.uid, user.email);
      } else if (previous?.value != null) {
        ref.read(fcmServiceProvider).unregisterToken(previous!.value!.uid);
      }
    });

    ref.listen(userNotificationsProvider, (previous, next) {
      final prevList = previous?.value;
      final nextList = next.value;
      if (prevList != null && nextList != null && nextList.isNotEmpty) {
        final prevIds = prevList.map((n) => n.id).toSet();
        final newItems =
            nextList.where((n) => !prevIds.contains(n.id)).toList();
        for (final item in newItems) {
          final isRecent =
              (DateTime.now().millisecondsSinceEpoch - item.createdAt).abs() <
                  120000;
          if (isRecent) {
            final source = item.isSensorRelated
                ? 'Sensor ${item.sensorId}'
                : 'Gateway ${item.gatewayId}';
            ref
                .read(notificationProvider.notifier)
                .showInfo('$source: ${item.typeLabel}');
          }
        }
      }
    });

    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFcm(ref, user.uid, user.email);
      });
    }

    return MaterialApp(
      title: 'Campersit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return AppNotificationListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
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
