import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart' as app_exceptions;
import 'package:crypto_wallet/features/auth/domain/entities/user_entity.dart';

/// Data source for authentication operations
/// Handles direct Supabase auth calls
abstract class AuthDatasource {
  /// Sign in with email and password
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and full name
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Reset password for given email
  Future<void> resetPassword({required String email});

  /// Get current authenticated user
  UserEntity? get currentUser;

  /// Stream of auth state changes
  Stream<bool> get authStateChanges;
}

/// Supabase implementation of AuthDatasource
class SupabaseAuthDatasource implements AuthDatasource {
  final SupabaseClient client;

  SupabaseAuthDatasource(this.client);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const app_exceptions.AuthException(
          message: 'Sign in failed',
          code: 'sign_in_failed',
        );
      }

      return _toUserEntity(response.user!);
    } on app_exceptions.AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw app_exceptions.AuthException(
        message: e.message,
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw app_exceptions.AuthException(
        message: 'An error occurred during sign in',
        code: 'unknown',
        originalError: e,
      );
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw const app_exceptions.AuthException(
          message: 'Sign up failed',
          code: 'sign_up_failed',
        );
      }

      return _toUserEntity(response.user!);
    } on app_exceptions.AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw app_exceptions.AuthException(
        message: e.message,
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw app_exceptions.AuthException(
        message: 'An error occurred during sign up',
        code: 'unknown',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } on app_exceptions.AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw app_exceptions.AuthException(
        message: e.message,
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw app_exceptions.AuthException(
        message: 'An error occurred during sign out',
        code: 'unknown',
        originalError: e,
      );
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on app_exceptions.AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw app_exceptions.AuthException(
        message: e.message,
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw app_exceptions.AuthException(
        message: 'An error occurred during password reset',
        code: 'unknown',
        originalError: e,
      );
    }
  }

  @override
  UserEntity? get currentUser {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return _toUserEntity(user);
  }

  @override
  Stream<bool> get authStateChanges {
    return client.auth.onAuthStateChange.map((state) {
      return state.session != null;
    });
  }

  /// Map Supabase error codes to app error codes
  String _mapErrorCode(String? code) {
    switch (code) {
      case 'Invalid login credentials':
        return 'invalid_credentials';
      case 'User not found':
        return 'user_not_found';
      case 'Password is too weak':
        return 'weak_password';
      case 'User already registered':
        return 'email_already_in_use';
      case 'Invalid email':
        return 'invalid_email';
      case 'User disabled':
        return 'user_disabled';
      default:
        return code ?? 'unknown';
    }
  }

  /// Convert Supabase User to UserEntity
  UserEntity _toUserEntity(User user) {
    return UserEntity(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
    );
  }
}
