/// A utility class for form validation in the merchant registration process
class FormValidators {
  /// Validates required fields
  static String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates email format (optional)
  static String? emailValidator(String? value) {
    // Email is optional, so return null if empty
    if (value == null || value.isEmpty) {
      return null;
    }

    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);

    if (!emailValid) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates mobile number format
  static String? mobileValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }

    return null;
  }

  /// Validates password strength
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // final bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    // final bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    // final bool hasNumber = value.contains(RegExp(r'[0-9]'));
    //
    // if (!hasUppercase || !hasLowercase || !hasNumber) {
    //   return 'Password must contain uppercase, lowercase, and number';
    // }

    return null;
  }

  /// Validates that passwords match
  static String? passwordMatchValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords don\'t match';
    }

    return null;
  }

  /// Validates business start year
  static String? yearValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }

    final int? year = int.tryParse(value);
    final int currentYear = DateTime.now().year;

    if (year == null) {
      return 'Please enter a valid year';
    }

    if (year < 1900 || year > currentYear) {
      return 'Year must be between 1900 and $currentYear';
    }

    return null;
  }

  /// Validates PAN card format
  static String? panCardValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final bool isPanValid = RegExp(
      r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
    ).hasMatch(value);

    if (!isPanValid) {
      return 'Enter a valid PAN card number';
    }

    return null;
  }

  /// Validates GSTIN format
  static String? gstinValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final bool isGstInValid = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    ).hasMatch(value);

    if (!isGstInValid) {
      return 'Enter a valid GSTIN number';
    }

    return null;
  }

  /// Validates pincode format
  static String? pinCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pin code is required';
    }

    if (value.length != 6) {
      return 'Pin code must be 6 digits';
    }

    return null;
  }
}
