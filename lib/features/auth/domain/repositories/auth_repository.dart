import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/auth/domain/entities/user_entity.dart';

/// Abstract repository for authentication operations
/// All auth operations should go through this interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and full name
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Reset password for given email
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Get current authenticated user
  Either<Failure, UserEntity?> get currentUser;

  /// Stream of auth state changes
  Stream<Either<Failure, bool>> get authStateChanges;
}
