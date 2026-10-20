import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/utils/date_time_formatter.dart';

void main() {
  group('convertDateTimeToString', () {
    test('formats DateTime with zero-padded day, month, hour, and minute', () {
      final dateTime = DateTime(2026, 3, 5, 8, 7);

      final result = convertDateTimeToString(dateTime);

      expect(result, equals('05/03/2026 08:07'));
    });

    test('formats DateTime with two-digit day, month, hour, and minute', () {
      final dateTime = DateTime(2026, 12, 25, 23, 59);

      final result = convertDateTimeToString(dateTime);

      expect(result, equals('25/12/2026 23:59'));
    });
  });

  group('formatDateTime', () {
    test('formats epoch milliseconds correctly', () {
      final dateTime = DateTime(2026, 10, 18, 14, 30);
      final epochMilliseconds = dateTime.millisecondsSinceEpoch;

      final result = formatDateTime(epochMilliseconds);

      expect(result, equals('18/10/2026 14:30'));
    });
  });
}
