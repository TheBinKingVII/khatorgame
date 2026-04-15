class InputValidator {
  static bool isValidEmail(String value) {
    if (value.trim().isEmpty) return false;
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(value);
  }

  static bool isStrongPassword(String value) {
    if (value.length < 8) return false;

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);

    return hasUppercase && hasLowercase && hasDigit;
  }
}
