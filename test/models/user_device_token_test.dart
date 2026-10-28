import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campersit_app/models/user_device_token.dart';

void main() {
  group('UserDeviceToken Model Tests', () {
    test('parses UserDeviceToken fromMap with Timestamp', () {
      final now = DateTime.now();
      final map = <String, Object?>{
        'fcmToken': 'fcm_sample_token_1234567890',
        'userAgent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120.0',
        'lastUpdated': Timestamp.fromDate(now),
      };

      final token = UserDeviceToken.fromMap('token_doc_1', map);

      expect(token.id, equals('token_doc_1'));
      expect(token.fcmToken, equals('fcm_sample_token_1234567890'));
      expect(token.userAgent, contains('Macintosh'));
      expect(token.lastUpdated, equals(now.millisecondsSinceEpoch));
      expect(token.deviceLabel, equals('Chrome on macOS'));
    });

    test('parses UserDeviceToken fromMap with null userAgent and null lastUpdated', () {
      final map = <String, Object?>{
        'fcmToken': 'fcm_sample_token_xyz',
      };

      final token = UserDeviceToken.fromMap('token_doc_2', map);

      expect(token.id, equals('token_doc_2'));
      expect(token.fcmToken, equals('fcm_sample_token_xyz'));
      expect(token.userAgent, isNull);
      expect(token.lastUpdated, isNull);
      expect(token.deviceLabel, equals('Unknown Device'));
    });

    test('deviceLabel correctly categorizes common platforms', () {
      expect(
        const UserDeviceToken(
          id: '1',
          fcmToken: 't',
          userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)',
        ).deviceLabel,
        equals('Apple iOS Device'),
      );

      expect(
        const UserDeviceToken(
          id: '2',
          fcmToken: 't',
          userAgent: 'Mozilla/5.0 (Linux; Android 14; SM-G991B)',
        ).deviceLabel,
        equals('Android Device'),
      );

      expect(
        const UserDeviceToken(
          id: '3',
          fcmToken: 't',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/119.0',
        ).deviceLabel,
        equals('Chrome on Windows'),
      );

      expect(
        const UserDeviceToken(
          id: '4',
          fcmToken: 't',
          userAgent: 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Firefox/119.0',
        ).deviceLabel,
        equals('Firefox on Linux'),
      );
    });

    test('converts UserDeviceToken toMap correctly', () {
      const token = UserDeviceToken(
        id: 'doc_123',
        fcmToken: 'token_abc',
        userAgent: 'Custom Agent',
        lastUpdated: 1718000000000,
      );

      final map = token.toMap();

      expect(map['fcmToken'], equals('token_abc'));
      expect(map['userAgent'], equals('Custom Agent'));
      expect(map['lastUpdated'], equals(1718000000000));
    });
  });
}
