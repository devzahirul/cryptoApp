import 'package:equatable/equatable.dart';

/// Base Failure class for error handling
/// All failures should extend this class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// Factory constructor for common auth errors
  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid_credentials':
        return const AuthFailure(
          message: 'Invalid email or password',
          code: 'invalid_credentials',
        );
      case 'user_not_found':
        return const AuthFailure(
          message: 'No account found with this email',
          code: 'user_not_found',
        );
      case 'weak_password':
        return const AuthFailure(
          message: 'Password must be at least 6 characters',
          code: 'weak_password',
        );
      case 'email_already_in_use':
        return const AuthFailure(
          message: 'This email is already registered',
          code: 'email_already_in_use',
        );
      case 'invalid_email':
        return const AuthFailure(
          message: 'Please enter a valid email address',
          code: 'invalid_email',
        );
      case 'user_disabled':
        return const AuthFailure(
          message: 'This account has been disabled',
          code: 'user_disabled',
        );
      case 'session_expired':
        return const AuthFailure(
          message: 'Your session has expired. Please sign in again.',
          code: 'session_expired',
        );
      default:
        return AuthFailure(
          message: 'Authentication failed',
          code: code,
        );
    }
  }
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection. Please check your network.',
      code: 'no_connection',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Connection timed out. Please try again.',
      code: 'timeout',
    );
  }

  factory NetworkFailure.serverError() {
    return const NetworkFailure(
      message: 'Server error. Please try again later.',
      code: 'server_error',
    );
  }

  factory NetworkFailure.badRequest() {
    return const NetworkFailure(
      message: 'Invalid request. Please try again.',
      code: 'bad_request',
    );
  }

  factory NetworkFailure.unauthorized() {
    return const NetworkFailure(
      message: 'Unauthorized access. Please sign in again.',
      code: 'unauthorized',
    );
  }

  factory NetworkFailure.forbidden() {
    return const NetworkFailure(
      message: 'Access denied. You don\'t have permission.',
      code: 'forbidden',
    );
  }

  factory NetworkFailure.notFound() {
    return const NetworkFailure(
      message: 'Resource not found.',
      code: 'not_found',
    );
  }

  factory NetworkFailure.unknown(String message) {
    return NetworkFailure(
      message: message.isEmpty ? 'Network error occurred' : message,
      code: 'unknown',
    );
  }
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });

  factory DatabaseFailure.fromCode(String code, String message) {
    switch (code) {
      case '42501': // RLS violation
        return DatabaseFailure(
          message: 'Permission denied. You can only access your own data.',
          code: 'permission_denied',
        );
      case '23505': // Unique violation
        return DatabaseFailure(
          message: 'A record with this value already exists.',
          code: 'duplicate',
        );
      case '23503': // Foreign key violation
        return DatabaseFailure(
          message: 'Referenced record does not exist.',
          code: 'reference_not_found',
        );
      default:
        return DatabaseFailure(
          message: message.isNotEmpty ? message : 'Database error occurred',
          code: code.isNotEmpty ? code : 'unknown',
        );
    }
  }
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });

  factory ValidationFailure.invalidEmail() {
    return const ValidationFailure(
      message: 'Please enter a valid email address',
      code: 'invalid_email',
    );
  }

  factory ValidationFailure.invalidPassword() {
    return const ValidationFailure(
      message: 'Password must be at least 6 characters',
      code: 'invalid_password',
    );
  }

  factory ValidationFailure.passwordsDontMatch() {
    return const ValidationFailure(
      message: 'Passwords do not match',
      code: 'passwords_dont_match',
    );
  }

  factory ValidationFailure.invalidAmount() {
    return const ValidationFailure(
      message: 'Please enter a valid amount',
      code: 'invalid_amount',
    );
  }

  factory ValidationFailure.insufficientBalance() {
    return const ValidationFailure(
      message: 'Insufficient balance for this transaction',
      code: 'insufficient_balance',
    );
  }

  factory ValidationFailure.invalidAddress() {
    return const ValidationFailure(
      message: 'Please enter a valid address',
      code: 'invalid_address',
    );
  }

  factory ValidationFailure.emptyField(String fieldName) {
    return ValidationFailure(
      message: '$fieldName is required',
      code: 'empty_field',
    );
  }
}

/// API failures (for external services like CoinGecko)
class ApiFailure extends Failure {
  const ApiFailure({
    required super.message,
    super.code,
  });

  factory ApiFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ApiFailure(
          message: 'Bad request. The API could not process your request.',
          code: 'bad_request',
        );
      case 401:
        return const ApiFailure(
          message: 'Unauthorized. Invalid API credentials.',
          code: 'unauthorized',
        );
      case 403:
        return const ApiFailure(
          message: 'Forbidden. API access denied.',
          code: 'forbidden',
        );
      case 404:
        return const ApiFailure(
          message: 'Resource not found.',
          code: 'not_found',
        );
      case 429:
        return const ApiFailure(
          message: 'Too many requests. Please try again later.',
          code: 'rate_limit',
        );
      case 500:
        return const ApiFailure(
          message: 'Internal server error. Please try again later.',
          code: 'server_error',
        );
      case 502:
      case 503:
        return const ApiFailure(
          message: 'Service unavailable. Please try again later.',
          code: 'service_unavailable',
        );
      default:
        return const ApiFailure(
          message: 'An error occurred while fetching data.',
          code: 'unknown',
        );
    }
  }
}

/// Generic/unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
  });

  factory UnknownFailure.fromException(Object exception) {
    return UnknownFailure(
      message: exception is String ? exception : exception.toString(),
      code: 'unknown',
    );
  }
}
