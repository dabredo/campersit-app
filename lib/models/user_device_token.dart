import 'package:cloud_firestore/cloud_firestore.dart';

class UserDeviceToken {
  final String id;
  final String fcmToken;
  final String? userAgent;
  final int? lastUpdated;

  const UserDeviceToken({
    required this.id,
    required this.fcmToken,
    this.userAgent,
    this.lastUpdated,
  });

  String get deviceLabel {
    final agent = userAgent;
    if (agent == null || agent.isEmpty) {
      return 'Unknown Device';
    }

    if (agent.contains('iPhone') || agent.contains('iPad')) {
      return 'Apple iOS Device';
    }
    if (agent.contains('Android')) {
      return 'Android Device';
    }
    if (agent.contains('Macintosh') || agent.contains('Mac OS')) {
      if (agent.contains('Chrome')) return 'Chrome on macOS';
      if (agent.contains('Safari')) return 'Safari on macOS';
      if (agent.contains('Firefox')) return 'Firefox on macOS';
      return 'macOS Device';
    }
    if (agent.contains('Windows')) {
      if (agent.contains('Chrome')) return 'Chrome on Windows';
      if (agent.contains('Firefox')) return 'Firefox on Windows';
      if (agent.contains('Edg')) return 'Edge on Windows';
      return 'Windows PC';
    }
    if (agent.contains('Linux')) {
      if (agent.contains('Chrome')) return 'Chrome on Linux';
      if (agent.contains('Firefox')) return 'Firefox on Linux';
      return 'Linux Device';
    }

    return 'Web Browser';
  }

  factory UserDeviceToken.fromMap(String id, Map<String, Object?> map) {
    final timestamp = map['lastUpdated'] as Timestamp?;
    return UserDeviceToken(
      id: id,
      fcmToken: map['fcmToken'] as String,
      userAgent: map['userAgent'] as String?,
      lastUpdated: timestamp?.millisecondsSinceEpoch,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'fcmToken': fcmToken,
      if (userAgent != null) 'userAgent': userAgent,
      if (lastUpdated != null) 'lastUpdated': lastUpdated,
    };
  }
}
