import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out current user
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    return await repository.signOut();
  }
}
