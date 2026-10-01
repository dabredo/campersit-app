import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppErrorFormatter {
  static String format(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-login-credentials':
          return 'Invalid email or password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again in a few moments.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'invalid-email':
          return 'The email address format is invalid.';
        case 'email-already-in-use':
          return 'An account already exists for this email address.';
        default:
          return 'Authentication failed. Please verify your credentials.';
      }
    }

    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'not-found':
          return 'The requested device or resource was not found.';
        case 'already-exists':
          return 'This device is already registered.';
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unauthenticated':
          return 'Your session has expired. Please sign in again.';
        case 'invalid-argument':
          return 'Invalid device ID format provided.';
        case 'deadline-exceeded':
          return 'The request timed out. Please try again.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again later.';
        default:
          return 'Unable to complete the operation. Please try again.';
      }
    }

    if (error is FirebaseException) {
      return 'A cloud service error occurred. Please try again.';
    }

    if (error is SocketException || error is TimeoutException) {
      return 'Connection error. Please check your internet connection and try again.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
