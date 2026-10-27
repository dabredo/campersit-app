import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/notification_repository.dart';

const String fcmWebVapidKey =
    'BCGlQ18KHDpwaohUgUG1sjZlD6iCDYh6otxnQYolWUODql3dAwlER45pPgvnpNL0AKDIjLDce_8b_t5RjcPt_78';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Entry point for background notifications processing
}

class FcmService {
  final FirebaseMessaging _messaging;
  final NotificationRepository _repository;
  String? _currentUserId;
  bool _isInitializing = false;

  FcmService({
    FirebaseMessaging? messaging,
    NotificationRepository? repository,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _repository = repository ?? NotificationRepository();

  Future<String?> _retrieveToken([String? customVapidKey]) {
    final effectiveVapidKey = customVapidKey ?? (kIsWeb ? fcmWebVapidKey : null);
    if (effectiveVapidKey != null) {
      return _messaging.getToken(vapidKey: effectiveVapidKey);
    }
    return _messaging.getToken();
  }

  Future<void> initialize({
    required String userId,
    String? userEmail,
    String? vapidKey,
    void Function(String title, String body)? onForegroundMessage,
  }) async {
    if (_currentUserId == userId || _isInitializing) return;
    _isInitializing = true;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('FCM: Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await _retrieveToken(vapidKey);
        debugPrint('FCM: Token retrieved: $token');
        if (token != null) {
          await _repository.saveDeviceToken(
            userId: userId,
            token: token,
            userEmail: userEmail,
          );
          _currentUserId = userId;
          debugPrint('FCM: Device token saved for user $userId');
        }

        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed: $newToken');
          _repository.saveDeviceToken(
            userId: userId,
            token: newToken,
            userEmail: userEmail,
          );
        });
      }

      // Foreground notification listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM: Foreground message received: id=${message.messageId}, '
          'notification=${message.notification?.title}, data=${message.data}',
        );
        final title = message.notification?.title ??
            message.data['title']?.toString() ??
            message.data['subject']?.toString() ??
            'Campersit Alert';
        final body = message.notification?.body ??
            message.data['body']?.toString() ??
            message.data['message']?.toString() ??
            message.data['text']?.toString() ??
            '';

        if (onForegroundMessage != null && (title.isNotEmpty || body.isNotEmpty)) {
          onForegroundMessage(title, body);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('FCM initialization warning: $e\n$stackTrace');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> unregisterToken(String userId, {String? vapidKey}) async {
    try {
      final token = await _retrieveToken(vapidKey);
      if (token != null) {
        await _repository.removeDeviceToken(userId: userId, token: token);
      }
      _currentUserId = null;
    } catch (e) {
      debugPrint('FCM unregister warning: $e');
    }
  }
}
