abstract class Validators {
  static String? required(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return '${label ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return re.hasMatch(value) ? null : 'Enter a valid email address';
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) return null;
    return value.length >= min ? null : 'Minimum $min characters';
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 ? null : 'Enter a valid phone number';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include a number';
    return null;
  }
}
