import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../utils/form_validators.dart';
import '../widgets/app_loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailAddressController = TextEditingController();
  final _accountPasswordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailAddressController.dispose();
    _accountPasswordController.dispose();
    super.dispose();
  }

  void _handleUserLogin() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    ref
        .read(loginControllerProvider.notifier)
        .login(
          _emailAddressController.text.trim(),
          _accountPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ref.read(notificationProvider.notifier).showError(next.error!);
      }
    });

    final loginState = ref.watch(loginControllerProvider);
    final isAuthenticating = loginState.isLoading;

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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildLoginForm(isAuthenticating),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
      ],
    );
  }

  Widget _buildLoginForm(bool isAuthenticating) {
    return Container(
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
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildSubmitButton(isAuthenticating),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailAddressController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'user@campersit.com',
        prefixIcon: Icon(Icons.alternate_email),
      ),
      validator: validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
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
      validator: validatePassword,
    );
  }

  Widget _buildSubmitButton(bool isAuthenticating) {
    return AppLoadingButton(
      isLoading: isAuthenticating,
      onPressed: _handleUserLogin,
      label: 'Login',
    );
  }
}
