import 'package:easy_localization/easy_localization.dart';

/// Centralized form validation logic for the app.
abstract final class FormValidators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates that a field is not empty.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.field_required'.tr(args: [fieldName]);
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    final empty = required(value, 'auth.email'.tr());
    if (empty != null) return empty;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'auth.email_invalid'.tr();
    }
    return null;
  }

  /// Validates password (min 6 characters).
  static String? password(String? value) {
    final empty = required(value, 'auth.password'.tr());
    if (empty != null) return empty;
    if (value!.length < 6) {
      return 'auth.password_min_length'.tr();
    }
    return null;
  }

  /// Validates that confirm password matches the original.
  static String? confirmPassword(String? value, String original) {
    final empty = required(value, 'auth.confirm_password'.tr());
    if (empty != null) return empty;
    if (value != original) {
      return 'auth.password_mismatch'.tr();
    }
    return null;
  }

  /// Validates username is not empty.
  static String? username(String? value) {
    return required(value, 'auth.username'.tr());
  }
}
