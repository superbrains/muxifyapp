import 'package:muxify/core/constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AppStrings.requiredField;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  /// Optional display name aligned with `/auth/register` (max 100 when set).
  static String? signupOptionalDisplayName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return null;
    return maxLength(t, 100, AppStrings.displayNameTooLong);
  }

  /// Register password rules (matches backend `RegisterCommandValidator`).
  static String? signupPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.requiredField;
    if (v.length < 8) return AppStrings.passwordTooShort;
    if (v.length > 128) return AppStrings.passwordTooLong;
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return AppStrings.passwordNeedsUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return AppStrings.passwordNeedsLowercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return AppStrings.passwordNeedsDigit;
    }
    return null;
  }

  /// Builds E.164 for Nigeria (+234) from the suffix field (leading 0 or 234 allowed).
  static String nigeriaPhoneSuffixToE164(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('234')) return '+$digits';
    if (digits.startsWith('0')) return '+234${digits.substring(1)}';
    return '+234$digits';
  }

  /// Validates the local phone suffix when +234 is shown separately in the UI.
  static String? signupNgPhoneSuffix(String? value) {
    final e164 = nigeriaPhoneSuffixToE164(value ?? '');
    if (e164.isEmpty) return AppStrings.requiredField;
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(e164)) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
      return AppStrings.invalidPhone;
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }

    if (value.length < 8) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }

    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }

    return null;
  }

  static String? minLength(String? value, int minLength, [String? message]) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }

    if (value.length < minLength) {
      return message ?? 'Minimum length is $minLength characters';
    }

    return null;
  }

  static String? maxLength(String? value, int maxLength, [String? message]) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return message ?? 'Maximum length is $maxLength characters';
    }

    return null;
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }
}
