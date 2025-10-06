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
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
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
