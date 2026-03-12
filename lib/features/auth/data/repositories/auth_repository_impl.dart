import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart' as app_exceptions;
import 'package:crypto_wallet/features/auth/domain/entities/user_entity.dart';
import 'package:crypto_wallet/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_wallet/features/auth/data/datasources/auth_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await datasource.signIn(email: email, password: password);
      return Right(user);
    } on app_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on app_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(user);
    } on app_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on app_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return const Right(null);
    } on app_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await datasource.resetPassword(email: email);
      return const Right(null);
    } on app_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, UserEntity?> get currentUser {
    try {
      final user = datasource.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No user signed in', code: 'no_user'));
      }
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, bool>> get authStateChanges {
    return datasource.authStateChanges.map((state) => Right(state) as Either<Failure, bool>);
  }
}
