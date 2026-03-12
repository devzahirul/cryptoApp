import 'package:intl/intl.dart';

/// DateTime extensions for common formatting operations
extension DateTimeX on DateTime {
  /// Format as short date (e.g., "Mar 12, 2026")
  String get shortDate => DateFormat('MMM d, yyyy').format(this);

  /// Format as time (e.g., "2:30 PM")
  String get time => DateFormat('h:mm a').format(this);

  /// Format as date and time (e.g., "Mar 12, 2026 2:30 PM")
  String get dateTime => DateFormat('MMM d, yyyy h:mm a').format(this);

  /// Format as relative time (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Format transaction date
  String get transactionDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return shortDate;
  }

  /// Format as ISO 8601 string
  String get iso8601 => toIso8601String();
}

/// DateTime? extension for null-safe formatting
extension NullableDateTimeX on DateTime? {
  /// Format as short date or return empty string if null
  String get shortDate => this?.shortDate ?? '';

  /// Format as time or return empty string if null
  String get time => this?.time ?? '';

  /// Format as date and time or return empty string if null
  String get dateTime => this?.dateTime ?? '';

  /// Format as relative time or return empty string if null
  String get relativeTime => this?.relativeTime ?? '';
}
