class AuthInputValidator {
  AuthInputValidator._();

  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    caseSensitive: false,
  );

  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static bool isValidEmail(String email) {
    return _emailPattern.hasMatch(normalizeEmail(email));
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isComplexPassword(String password) {
    return getMissingPasswordRequirements(password).isEmpty;
  }

  static List<String> getMissingPasswordRequirements(String password) {
    final missing = <String>[];

    if (password.length < 8) {
      missing.add('minLength');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      missing.add('uppercase');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      missing.add('lowercase');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      missing.add('number');
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      missing.add('symbol');
    }

    return missing;
  }

  static bool isValidHttpUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return true;
    }

    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
