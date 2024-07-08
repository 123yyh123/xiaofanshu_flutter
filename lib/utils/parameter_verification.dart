class ParameterVerification {
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  static bool isPhoneNumber(String value) {
    return RegExp(r'^1[3456789]\d{9}$').hasMatch(value);
  }
}
