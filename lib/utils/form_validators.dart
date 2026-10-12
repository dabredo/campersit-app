String? validateRequiredField(String? value, String fieldName) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? 'Please enter your $fieldName' : null;
}

String? validateEmail(String? value) {
  final requiredFieldError = validateRequiredField(value, 'email address');
  if (requiredFieldError != null) return requiredFieldError;

  final trimmed = value!.trim();
  final isValidEmailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmed);
  if (!isValidEmailPattern) {
    return 'Please enter a valid email format';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  const minimumPasswordLength = 6;
  if (value.length < minimumPasswordLength) {
    return 'Password must be at least $minimumPasswordLength characters';
  }
  return null;
}

String? validateMacAddress(String? value) {
  final requiredFieldError = validateRequiredField(value, 'Gateway ID');
  if (requiredFieldError != null) return requiredFieldError;

  final trimmed = value!.trim();
  final isValidMacPattern = RegExp(
    r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$',
  ).hasMatch(trimmed);
  if (!isValidMacPattern) {
    return 'Please enter a valid MAC address (e.g. AA:BB:CC:11:22:33)';
  }
  return null;
}

