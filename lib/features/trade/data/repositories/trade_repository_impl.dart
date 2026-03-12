import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/features/trade/domain/repositories/trade_repository.dart';
import 'package:crypto_wallet/features/trade/data/datasources/trade_datasource.dart';

/// Implementation of TradeRepository
class TradeRepositoryImpl implements TradeRepository {
  final TradeDatasource datasource;

  TradeRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, (double btcAmount, TransactionEntity transaction)>> buyBtc({
    required double usdAmount,
    required double btcPrice,
  }) async {
    try {
      final (wallet, transaction) = await datasource.buyBtc(
        usdAmount: usdAmount,
        btcPrice: btcPrice,
      );
      return Right((transaction.amountBtc ?? 0, transaction));
    } on TradeException catch (e) {
      if (e.code == 'insufficient_funds') {
        return Left(ValidationFailure.insufficientBalance());
      }
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, (double usdAmount, TransactionEntity transaction)>> sellBtc({
    required double btcAmount,
    required double btcPrice,
  }) async {
    try {
      final (wallet, transaction) = await datasource.sellBtc(
        btcAmount: btcAmount,
        btcPrice: btcPrice,
      );
      return Right((transaction.amountUsd ?? 0, transaction));
    } on TradeException catch (e) {
      if (e.code == 'insufficient_funds') {
        return Left(ValidationFailure.insufficientBalance());
      }
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
