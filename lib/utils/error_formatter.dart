import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppErrorFormatter {
  static String format(Object error) => switch (error) {
    FirebaseAuthException(:final code) => switch (code) {
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' ||
      'invalid-login-credentials' =>
        'Invalid email or password. Please try again.',
      'user-disabled' =>
        'This account has been disabled. Please contact support.',
      'too-many-requests' =>
        'Too many attempts. Please try again in a few moments.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      'invalid-email' => 'The email address format is invalid.',
      'email-already-in-use' =>
        'An account already exists for this email address.',
      _ => 'Authentication failed. Please verify your credentials.',
    },
    FirebaseFunctionsException(:final code) => switch (code) {
      'not-found' => 'The requested device or resource was not found.',
      'already-exists' => 'This device is already registered.',
      'permission-denied' =>
        'You do not have permission to perform this action.',
      'unauthenticated' => 'Your session has expired. Please sign in again.',
      'invalid-argument' => 'Invalid device ID format provided.',
      'deadline-exceeded' => 'The request timed out. Please try again.',
      'unavailable' =>
        'Service temporarily unavailable. Please try again later.',
      _ => 'Unable to complete the operation. Please try again.',
    },
    FirebaseException() => 'A cloud service error occurred. Please try again.',
    SocketException() ||
    TimeoutException() =>
      'Connection error. Please check your internet connection and try again.',
    _ => 'An unexpected error occurred. Please try again.',
  };
}
