import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/transfer/data/datasources/transfer_datasource.dart';
import 'package:crypto_wallet/features/transfer/domain/repositories/transfer_repository.dart';

/// Implementation of TransferRepository
class TransferRepositoryImpl implements TransferRepository {
  final TransferDatasource datasource;

  TransferRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, SendResult>> sendBtc({
    required String recipientAddress,
    required double btcAmount,
  }) async {
    try {
      final result = await datasource.sendBtc(
        recipientAddress: recipientAddress,
        btcAmount: btcAmount,
      );
      return Right(result);
    } on TransferException catch (e) {
      if (e.code == 'insufficient_funds') {
        return Left(ValidationFailure.insufficientBalance());
      }
      if (e.code == 'wallet_not_found') {
        return Left(ValidationFailure(message: 'Wallet not found', code: 'wallet_not_found'));
      }
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getReceiveAddress() async {
    try {
      final address = await datasource.getReceiveAddress();
      return Right(address);
    } on TransferException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInternalAddress(String address) async {
    try {
      final isInternal = await datasource.isInternalAddress(address);
      return Right(isInternal);
    } on TransferException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
