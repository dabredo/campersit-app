import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gateway_notification.dart';
import '../models/notification_preference.dart';
import '../models/user_device_token.dart';
import '../utils/user_agent_reader.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _resolveTokenDocId(String token) {
    final bytes = utf8.encode(token);
    final base64String = base64.encode(bytes);
    return base64String.length >= 20
        ? base64String.substring(0, 20).replaceAll('/', '_')
        : base64String.replaceAll('/', '_');
  }

  Stream<List<GatewayNotification>> watchNotificationsForGateways(
    List<String> gatewayIds, {
    int limit = 50,
  }) {
    if (gatewayIds.isEmpty) {
      return Stream.value(const []);
    }

    // Firestore whereIn has a limit of 30 values
    final queryIds = gatewayIds.take(30).toList();

    return _firestore
        .collection('notifications')
        .where('gatewayId', whereIn: queryIds)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            return GatewayNotification.fromMap(doc.id, doc.data());
          }).toList();

          // Sort in-memory to avoid requiring a composite index
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items.take(limit).toList();
        });
  }

  Stream<List<GatewayNotification>> watchGatewayNotifications(
    String gatewayId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('notifications')
        .where('gatewayId', isEqualTo: gatewayId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            return GatewayNotification.fromMap(doc.id, doc.data());
          }).toList();

          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items.take(limit).toList();
        });
  }

  Future<void> saveDeviceToken({
    required String userId,
    required String token,
    String? userAgent,
    String? userEmail,
  }) async {
    final tokenDocId = _resolveTokenDocId(token);

    final tokenRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('browsers')
        .doc(tokenDocId);

    final batch = _firestore.batch();
    batch.set(
      tokenRef,
      {
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userAgent': userAgent ?? getUserAgent(),
      },
      SetOptions(merge: true),
    );

    if (userEmail != null) {
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(
        userRef,
        {'email': userEmail},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> removeDeviceToken({
    required String userId,
    required String token,
  }) async {
    final tokenDocId = _resolveTokenDocId(token);

    final tokenRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('browsers')
        .doc(tokenDocId);

    await tokenRef.delete();
  }

  Stream<List<UserDeviceToken>> watchDeviceTokens(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('browsers')
        .snapshots()
        .map((snapshot) {
          final tokens = snapshot.docs.map((doc) {
            return UserDeviceToken.fromMap(doc.id, doc.data());
          }).toList();

          tokens.sort((a, b) {
            final aTime = a.lastUpdated ?? 0;
            final bTime = b.lastUpdated ?? 0;
            return bTime.compareTo(aTime);
          });
          return tokens;
        });
  }

  Future<void> removeDeviceTokenById({
    required String userId,
    required String docId,
  }) async {
    final tokenRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('browsers')
        .doc(docId);

    await tokenRef.delete();
  }

  Stream<Map<String, NotificationPreference>> watchNotificationPreferences(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          final notificationsMap =
              data?['notifications'] as Map<String, dynamic>?;
          if (notificationsMap == null) {
            return const {};
          }

          final preferences = <String, NotificationPreference>{};
          for (final entry in notificationsMap.entries) {
            final value = entry.value as Map<String, dynamic>;
            preferences[entry.key] = NotificationPreference.fromMap(
              entry.key,
              value,
            );
          }
          return preferences;
        });
  }

  Future<void> updateNotificationPreference({
    required String userId,
    required String eventType,
    required bool app,
    required bool email,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.set(
      {
        'notifications': {
          eventType: {
            'app': app,
            'email': email,
          },
        },
      },
      SetOptions(merge: true),
    );
  }
}
