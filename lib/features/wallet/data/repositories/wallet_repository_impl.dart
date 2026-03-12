import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:crypto_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:crypto_wallet/features/wallet/data/datasources/wallet_datasource.dart';

/// Implementation of WalletRepository
class WalletRepositoryImpl implements WalletRepository {
  final WalletDatasource datasource;

  WalletRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    try {
      final wallet = await datasource.getWallet();
      return Right(wallet);
    } on WalletException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> updateBalances({
    double? usdBalance,
    double? btcBalance,
  }) async {
    try {
      final wallet = await datasource.updateBalances(
        usdBalance: usdBalance,
        btcBalance: btcBalance,
      );
      return Right(wallet);
    } on WalletException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateBtcAddress() async {
    try {
      final address = await datasource.generateBtcAddress();
      return Right(address);
    } on WalletException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
