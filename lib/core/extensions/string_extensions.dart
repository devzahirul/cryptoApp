import 'package:intl/intl.dart';

/// String extensions for common validation and formatting operations
extension StringX on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid BTC address (mock validation for MVP)
  bool get isValidBtcAddress {
    // Simple validation - in production, use proper BTC address validation
    return length >= 26 && length <= 62;
  }

  /// Check if string is empty or whitespace only
  bool get isNullOrEmpty {
    return trim().isEmpty;
  }

  /// Check if string is not empty
  bool get isNotNullOrEmpty {
    return trim().isNotEmpty;
  }

  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Format as currency (USD)
  String get asCurrency {
    final number = double.tryParse(this) ?? 0;
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(number);
  }

  /// Format as BTC amount (8 decimal places)
  String get asBtc {
    final number = double.tryParse(this) ?? 0;
    return NumberFormat.decimalPattern('en_US').format(number);
  }

  /// Format as percentage
  String get asPercentage {
    final number = double.tryParse(this) ?? 0;
    return NumberFormat.percentPattern('en_US').format(number / 100);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Mask string for sensitive data (e.g., "****1234")
  String mask({int visibleChars = 4, String maskChar = '*'}) {
    if (length <= visibleChars) return this;
    return maskChar * (length - visibleChars) + substring(length - visibleChars);
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s'), '');

  /// Check if string contains only numbers
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Parse to DateTime from ISO 8601 string
  DateTime? toDateTime() {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Parse to double
  double? toDouble() {
    return double.tryParse(this);
  }

  /// Parse to int
  int? toInt() {
    return int.tryParse(this);
  }
}

/// String? extension for null-safe operations
extension NullableStringX on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this?.trim().isEmpty ?? true;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => this?.trim().isNotEmpty ?? true;

  /// Return this or default value if null/empty
  String orEmpty() => this ?? '';

  /// Return this or default value
  String orDefault(String defaultValue) => this ?? defaultValue;
}
