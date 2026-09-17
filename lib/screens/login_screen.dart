import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart' show applicationAuthenticationService;
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailAddressController = TextEditingController();
  final _accountPasswordController = TextEditingController();

  bool _isAuthenticating = false;
  bool _isPasswordObscured = true;
  String? _authenticationErrorMessage;

  @override
  void dispose() {
    _emailAddressController.dispose();
    _accountPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUserLogin() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    setState(() {
      _isAuthenticating = true;
      _authenticationErrorMessage = null;
    });

    try {
      await applicationAuthenticationService.signInWithCredentials(
        emailAddress: _emailAddressController.text.trim(),
        accountPassword: _accountPasswordController.text,
      );
    } on FirebaseAuthException catch (authException) {
      final readableErrorMessage = switch (authException.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Incorrect credentials. Please verify your email and password.',
        'invalid-email' => 'The provided email address format is invalid.',
        'user-disabled' => 'This user account has been disabled.',
        'too-many-requests' =>
          'Too many failed attempts. Please try again later.',
        _ =>
          authException.message ?? 'Authentication failed. Please try again.',
      };

      if (!mounted) return;
      setState(() {
        _authenticationErrorMessage = readableErrorMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authenticationErrorMessage =
            'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Campersit Security Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_authenticationErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _authenticationErrorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: AppRadius.border2Xl,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailAddressController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'operator@campersit.io',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (inputValue) {
                            final trimmedValue = inputValue?.trim() ?? '';
                            if (trimmedValue.isEmpty) {
                              return 'Please enter your email address';
                            }
                            final isEmailPatternValid = RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(trimmedValue);
                            if (!isEmailPatternValid) {
                              return 'Please enter a valid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _accountPasswordController,
                          obscureText: _isPasswordObscured,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                          validator: (inputValue) {
                            if (inputValue == null || inputValue.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (inputValue.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isAuthenticating
                              ? null
                              : _handleUserLogin,
                          child: _isAuthenticating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
