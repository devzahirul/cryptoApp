import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/auth/domain/entities/user_entity.dart';
import 'package:crypto_wallet/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.trim().isEmpty) {
      return Left(const ValidationFailure(message: 'Email is required', code: 'empty_email'));
    }
    if (password.isEmpty) {
      return Left(const ValidationFailure(message: 'Password is required', code: 'empty_password'));
    }

    // Call repository
    return await repository.signIn(email: email, password: password);
  }
}
