import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/auth/domain/entities/user_entity.dart';
import 'package:crypto_wallet/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing up with email, password, and full name
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validate input
    if (email.trim().isEmpty) {
      return Left(const ValidationFailure(message: 'Email is required', code: 'empty_email'));
    }
    if (password.isEmpty) {
      return Left(const ValidationFailure(message: 'Password is required', code: 'empty_password'));
    }
    if (password.length < 6) {
      return Left(const ValidationFailure(message: 'Password must be at least 6 characters', code: 'weak_password'));
    }
    if (fullName.trim().isEmpty) {
      return Left(const ValidationFailure(message: 'Full name is required', code: 'empty_name'));
    }

    // Call repository
    return await repository.signUp(email: email, password: password, fullName: fullName);
  }
}
