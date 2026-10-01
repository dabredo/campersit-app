import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/utils/error_formatter.dart';

void main() {
  group('AppErrorFormatter Tests', () {
    group('FirebaseAuthException handling', () {
      test('formats invalid-credential code', () {
        final exception = FirebaseAuthException(code: 'invalid-credential');
        expect(
          AppErrorFormatter.format(exception),
          equals('Invalid email or password. Please try again.'),
        );
      });

      test('formats wrong-password code', () {
        final exception = FirebaseAuthException(code: 'wrong-password');
        expect(
          AppErrorFormatter.format(exception),
          equals('Invalid email or password. Please try again.'),
        );
      });

      test('formats user-disabled code', () {
        final exception = FirebaseAuthException(code: 'user-disabled');
        expect(
          AppErrorFormatter.format(exception),
          equals('This account has been disabled. Please contact support.'),
        );
      });

      test('formats too-many-requests code', () {
        final exception = FirebaseAuthException(code: 'too-many-requests');
        expect(
          AppErrorFormatter.format(exception),
          equals('Too many attempts. Please try again in a few moments.'),
        );
      });

      test('formats network-request-failed code', () {
        final exception = FirebaseAuthException(code: 'network-request-failed');
        expect(
          AppErrorFormatter.format(exception),
          equals('Network error. Please check your internet connection.'),
        );
      });

      test('formats invalid-email code', () {
        final exception = FirebaseAuthException(code: 'invalid-email');
        expect(
          AppErrorFormatter.format(exception),
          equals('The email address format is invalid.'),
        );
      });

      test('formats email-already-in-use code', () {
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        expect(
          AppErrorFormatter.format(exception),
          equals('An account already exists for this email address.'),
        );
      });

      test('formats unknown auth code with default message', () {
        final exception = FirebaseAuthException(code: 'unknown-code');
        expect(
          AppErrorFormatter.format(exception),
          equals('Authentication failed. Please verify your credentials.'),
        );
      });
    });

    group('FirebaseFunctionsException handling', () {
      test('formats not-found code', () {
        final exception = FirebaseFunctionsException(
          message: 'Raw server trace',
          code: 'not-found',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('The requested device or resource was not found.'),
        );
      });

      test('formats already-exists code', () {
        final exception = FirebaseFunctionsException(
          message: 'Internal duplicate',
          code: 'already-exists',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('This device is already registered.'),
        );
      });

      test('formats permission-denied code', () {
        final exception = FirebaseFunctionsException(
          message: 'Forbidden access',
          code: 'permission-denied',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('You do not have permission to perform this action.'),
        );
      });

      test('formats unauthenticated code', () {
        final exception = FirebaseFunctionsException(
          message: 'Token expired',
          code: 'unauthenticated',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('Your session has expired. Please sign in again.'),
        );
      });

      test('formats invalid-argument code', () {
        final exception = FirebaseFunctionsException(
          message: 'Malformed input',
          code: 'invalid-argument',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('Invalid device ID format provided.'),
        );
      });

      test('formats deadline-exceeded code', () {
        final exception = FirebaseFunctionsException(
          message: 'Timeout on backend',
          code: 'deadline-exceeded',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('The request timed out. Please try again.'),
        );
      });

      test('formats unavailable code', () {
        final exception = FirebaseFunctionsException(
          message: 'Service down',
          code: 'unavailable',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('Service temporarily unavailable. Please try again later.'),
        );
      });

      test('formats unknown functions code with default message', () {
        final exception = FirebaseFunctionsException(
          message: 'Internal server error details',
          code: 'internal',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('Unable to complete the operation. Please try again.'),
        );
      });
    });

    group('Generic Firebase and System Exception handling', () {
      test('formats FirebaseException with generic cloud service message', () {
        final exception = FirebaseException(
          plugin: 'firestore',
          message: 'Raw firestore internal permission message',
        );
        expect(
          AppErrorFormatter.format(exception),
          equals('A cloud service error occurred. Please try again.'),
        );
      });

      test('formats SocketException with connection error message', () {
        const exception = SocketException('Failed host lookup');
        expect(
          AppErrorFormatter.format(exception),
          equals('Connection error. Please check your internet connection and try again.'),
        );
      });

      test('formats TimeoutException with connection error message', () {
        final exception = TimeoutException('Future timed out');
        expect(
          AppErrorFormatter.format(exception),
          equals('Connection error. Please check your internet connection and try again.'),
        );
      });

      test('formats unknown generic object with unexpected error fallback', () {
        final exception = Exception('Unknown arbitrary error');
        expect(
          AppErrorFormatter.format(exception),
          equals('An unexpected error occurred. Please try again.'),
        );
      });
    });
  });
}
