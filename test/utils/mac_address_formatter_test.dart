import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/utils/mac_address_formatter.dart';

void main() {
  group('MacAddressInputFormatter', () {
    late MacAddressInputFormatter formatter;

    setUp(() {
      formatter = MacAddressInputFormatter();
    });

    test('formats lowercase hex input into uppercase with colons', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'aabbcc112233');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('AA:BB:CC:11:22:33'));
      expect(result.selection.baseOffset, equals(17));
    });

    test('ignores non-hex characters', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'gg-11-22-33-44-55-zz');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('11:22:33:44:55'));
    });

    test('caps at 12 hex digits (6 bytes)', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'AABBCCDDEEFF0011');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('AA:BB:CC:DD:EE:FF'));
    });

    test('handles backspace deletion over colon separator', () {
      const oldValue = TextEditingValue(
        text: 'AA:BB:',
        selection: TextSelection.collapsed(offset: 6),
      );
      const newValue = TextEditingValue(
        text: 'AA:BB',
        selection: TextSelection.collapsed(offset: 5),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('AA:B'));
    });
  });
}
