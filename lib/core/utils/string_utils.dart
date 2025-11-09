class StringUtils {
  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Capitalizes the first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Converts camelCase to readable text
  static String camelCaseToWords(String camelCase) {
    return camelCase
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim();
  }
  
  /// Converts snake_case to readable text
  static String snakeCaseToWords(String snakeCase) {
    return snakeCase.replaceAll('_', ' ');
  }
  
  /// Truncates text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Generates a random hex color
  static String randomHexColor() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return '#${(random & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
  
  /// Formats number with K, M, B suffixes
  static String formatNumber(num number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validates password strength
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }
  
  /// Generates random string
  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random % chars.length),
    ));
  }
  
  /// Removes all whitespace
  static String removeAllWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }
  
  /// Formats currency in INR
  static String formatCurrency(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)} K';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
  
  /// Pluralize word based on count
  static String pluralize(String word, int count) {
    if (count == 1) return word;
    
    // Handle common irregular plurals
    final irregulars = {
      'child': 'children',
      'person': 'people',
      'man': 'men',
      'woman': 'women',
      'tooth': 'teeth',
      'foot': 'feet',
      'mouse': 'mice',
      'goose': 'geese',
    };
    
    if (irregulars.containsKey(word.toLowerCase())) {
      return irregulars[word.toLowerCase()]!;
    }
    
    // Handle regular plurals
    if (word.endsWith('y') && !RegExp(r'[aeiou]y$').hasMatch(word)) {
      return '${word.substring(0, word.length - 1)}ies';
    }
    if (word.endsWith('s') || word.endsWith('sh') || word.endsWith('ch') || 
        word.endsWith('x') || word.endsWith('z')) {
      return '${word}es';
    }
    if (word.endsWith('f')) {
      return '${word.substring(0, word.length - 1)}ves';
    }
    if (word.endsWith('fe')) {
      return '${word.substring(0, word.length - 2)}ves';
    }
    
    return '${word}s';
  }
  
  /// Generate slug from text
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Extract initials from name
  static String getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
  
  /// Check if string is numeric
  static bool isNumeric(String text) {
    return double.tryParse(text) != null;
  }
  
  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }
}
