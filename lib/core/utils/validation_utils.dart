class ValidationUtils {
  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validates password strength
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    return password.length >= 8;
  }
  
  /// Validates strong password
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigits = RegExp(r'\d').hasMatch(password);
    bool hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }
  
  /// Validates phone number (Indian format)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Indian phone number: +91xxxxxxxxxx or xxxxxxxxxx
    return RegExp(r'^(\+91|0)?[6-9]\d{9}$').hasMatch(phone);
  }
  
  /// Validates name
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    return name.trim().length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }
  
  /// Validates username
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    return username.length >= 3 && 
           username.length <= 20 && 
           RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
  
  /// Validates URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    return RegExp(r'^https?:\/\/([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w\-\._~:?#[\]@!\$&\'\(\)\*\+,;=.]+)?$').hasMatch(url);
  }
  
  /// Validates age
  static bool isValidAge(int age) {
    return age >= 13 && age <= 120;
  }
  
  /// Validates positive number
  static bool isPositiveNumber(String value) {
    if (value.isEmpty) return false;
    final number = double.tryParse(value);
    return number != null && number > 0;
  }
  
  /// Validates non-negative number
  static bool isNonNegativeNumber(String value) {
    if (value.isEmpty) return false;
    final number = double.tryParse(value);
    return number != null && number >= 0;
  }
  
  /// Validates integer
  static bool isInteger(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null;
  }
  
  /// Validates decimal
  static bool isDecimal(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }
  
  /// Validates date format (dd/MM/yyyy)
  static bool isValidDateFormat(String date) {
    if (date.isEmpty) return false;
    return RegExp(r'^\d{2}\/\d{2}\/\d{4}$').hasMatch(date);
  }
  
  /// Validates time format (HH:mm)
  static bool isValidTimeFormat(String time) {
    if (time.isEmpty) return false;
    return RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);
  }
  
  /// Validates hex color
  static bool isValidHexColor(String color) {
    if (color.isEmpty) return false;
    return RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(color);
  }
  
  /// Validates file extension
  static bool isValidFileExtension(String filename, List<String> allowedExtensions) {
    if (filename.isEmpty) return false;
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  /// Validates minimum length
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }
  
  /// Validates maximum length
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }
  
  /// Validates length range
  static bool isLengthInRange(String value, int minLength, int maxLength) {
    return value.length >= minLength && value.length <= maxLength;
  }
  
  /// Validates contains only letters
  static bool isAlphabetic(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(value);
  }
  
  /// Validates contains only numbers
  static bool isNumeric(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
  
  /// Validates alphanumeric
  static bool isAlphanumeric(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }
  
  /// Validates not empty
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }
  
  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validates email field
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  /// Validates password field
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
  
  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Validates name field
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(value)) {
      return 'Please enter a valid name';
    }
    return null;
  }
  
  /// Validates phone number field
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validates age field
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (!isValidAge(age)) {
      return 'Age must be between 13 and 120';
    }
    return null;
  }
}
