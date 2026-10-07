import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/utils/form_validators.dart';

void main() {
  group('validateRequiredField', () {
    test('returns error message when value is null', () {
      expect(
        validateRequiredField(null, 'username'),
        equals('Please enter your username'),
      );
    });

    test('returns error message when value is empty', () {
      expect(
        validateRequiredField('', 'username'),
        equals('Please enter your username'),
      );
    });

    test('returns error message when value is only whitespace', () {
      expect(
        validateRequiredField('   ', 'username'),
        equals('Please enter your username'),
      );
    });

    test('returns null when value has content', () {
      expect(validateRequiredField('some value', 'username'), isNull);
    });

    test('returns null when value has content surrounded by whitespace', () {
      expect(validateRequiredField('  some value  ', 'username'), isNull);
    });

    test('interpolates the field name into the error message', () {
      expect(
        validateRequiredField(null, 'Gateway ID'),
        equals('Please enter your Gateway ID'),
      );
    });
  });

  group('validateEmail', () {
    group('required field check', () {
      test('returns error when value is null', () {
        expect(validateEmail(null), equals('Please enter your email address'));
      });

      test('returns error when value is empty', () {
        expect(validateEmail(''), equals('Please enter your email address'));
      });

      test('returns error when value is only whitespace', () {
        expect(
          validateEmail('   '),
          equals('Please enter your email address'),
        );
      });
    });

    group('format check', () {
      test('returns error when email has no @ symbol', () {
        expect(
          validateEmail('notanemail'),
          equals('Please enter a valid email format'),
        );
      });

      test('returns error when email has no domain', () {
        expect(
          validateEmail('user@'),
          equals('Please enter a valid email format'),
        );
      });

      test('returns error when email has no TLD', () {
        expect(
          validateEmail('user@domain'),
          equals('Please enter a valid email format'),
        );
      });
    });

    group('valid emails', () {
      test('returns null for a standard email address', () {
        expect(validateEmail('user@campersit.com'), isNull);
      });

      test('returns null for an email with subdomains', () {
        expect(validateEmail('user@mail.campersit.com'), isNull);
      });

      test('returns null when email is surrounded by whitespace', () {
        expect(validateEmail('  user@campersit.com  '), isNull);
      });
    });
  });

  group('validatePassword', () {
    group('required field check', () {
      test('returns error when value is null', () {
        expect(
          validatePassword(null),
          equals('Please enter your password'),
        );
      });

      test('returns error when value is empty', () {
        expect(
          validatePassword(''),
          equals('Please enter your password'),
        );
      });
    });

    group('minimum length check', () {
      test('returns error when password is shorter than 6 characters', () {
        expect(
          validatePassword('abc'),
          equals('Password must be at least 6 characters'),
        );
      });

      test('returns error when password is exactly 5 characters', () {
        expect(
          validatePassword('abcde'),
          equals('Password must be at least 6 characters'),
        );
      });

      test('returns null when password is exactly 6 characters', () {
        expect(validatePassword('abcdef'), isNull);
      });

      test('returns null when password exceeds minimum length', () {
        expect(validatePassword('a-strong-password-123!'), isNull);
      });
    });
  });
}
