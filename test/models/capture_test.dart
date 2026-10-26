import 'package:campersit_app/models/capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Capture Model', () {
    test('creates Capture from valid map', () {
      final map = <String, Object?>{
        'userId': 'user-123',
        'deviceId': 'gw-001',
        'sensorId': 'cam-01',
        'url': 'https://firebasestorage.googleapis.com/v0/b/bucket/o/video.mp4',
        'createdAt': 1718000000000,
      };

      final capture = Capture.fromMap('cap-999', map);

      expect(capture.id, equals('cap-999'));
      expect(capture.userId, equals('user-123'));
      expect(capture.deviceId, equals('gw-001'));
      expect(capture.sensorId, equals('cam-01'));
      expect(
        capture.url,
        equals(
          'https://firebasestorage.googleapis.com/v0/b/bucket/o/video.mp4',
        ),
      );
      expect(capture.createdAt, equals(1718000000000));
    });

    test('serializes Capture toMap accurately', () {
      const capture = Capture(
        id: 'cap-999',
        userId: 'user-123',
        deviceId: 'gw-001',
        sensorId: 'cam-01',
        url: 'https://firebasestorage.googleapis.com/v0/b/bucket/o/video.mp4',
        createdAt: 1718000000000,
      );

      final map = capture.toMap();

      expect(map['userId'], equals('user-123'));
      expect(map['deviceId'], equals('gw-001'));
      expect(map['sensorId'], equals('cam-01'));
      expect(
        map['url'],
        equals(
          'https://firebasestorage.googleapis.com/v0/b/bucket/o/video.mp4',
        ),
      );
      expect(map['createdAt'], equals(1718000000000));
    });
  });
}
