import 'package:flutter/services.dart';

class InputValidator {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'\d');
  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _suspiciousPattern = RegExp(
    r'(--|;|/\*|\*/|\b(select|insert|update|delete|drop|union|alter|truncate|exec)\b|\bor\b\s+1=1)',
    caseSensitive: false,
  );

  static final List<TextInputFormatter> nameFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(50),
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 .'\-]")),
  ];

  static final List<TextInputFormatter> emailFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(100),
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];

  static final List<TextInputFormatter> passwordFormatters =
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(64),
        FilteringTextInputFormatter.deny(_controlChars),
      ];

  static final List<TextInputFormatter> searchFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(60),
    FilteringTextInputFormatter.deny(_controlChars),
  ];

  static final List<TextInputFormatter> chatFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(240),
    FilteringTextInputFormatter.deny(_controlChars),
  ];

  static bool isValidEmail(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) return false;
    if (_hasSuspiciousPattern(normalized)) return false;
    return _emailRegex.hasMatch(normalized);
  }

  static bool isStrongPassword(String value) {
    if (value.length < 8) return false;
    if (_hasSuspiciousPattern(value)) return false;
    return _hasUppercase.hasMatch(value) &&
        _hasLowercase.hasMatch(value) &&
        _hasDigit.hasMatch(value);
  }

  static String? validateFullName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    if (_hasSuspiciousPattern(text)) return 'Input tidak valid';
    return null;
  }

  static String? validateEmail(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!isValidEmail(text)) return 'Format email tidak valid';
    return null;
  }

  static String? validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Password wajib diisi';
    if (text.length < 8) return 'Minimal 8 karakter';
    if (text.length > 64) return 'Maksimal 64 karakter';
    if (_hasSuspiciousPattern(text)) return 'Input tidak valid';
    return null;
  }

  static String? validateSearchQuery(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > 60) return 'Maksimal 60 karakter';
    if (_hasSuspiciousPattern(text)) return 'Kata kunci tidak valid';
    return null;
  }

  static String? validateChatMessage(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Pesan tidak boleh kosong';
    if (text.length > 240) return 'Maksimal 240 karakter';
    if (_hasSuspiciousPattern(text)) return 'Pesan mengandung pola tidak valid';
    return null;
  }

  static bool _hasSuspiciousPattern(String value) {
    return _suspiciousPattern.hasMatch(value);
  }
}
