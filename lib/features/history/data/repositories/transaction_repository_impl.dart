import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/features/history/domain/repositories/transaction_repository.dart';
import 'package:crypto_wallet/features/history/data/datasources/transaction_datasource.dart';

/// Implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  }) async {
    try {
      final transactions = await datasource.getTransactions(
        page: page,
        limit: limit,
        type: type,
      );
      return Right(transactions);
    } on TransactionException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required TransactionType type,
    required double amountBtc,
    double? amountUsd,
    double? btcPriceAtTime,
    String? fromAddress,
    String? toAddress,
  }) async {
    try {
      final transaction = await datasource.createTransaction(
        type: type,
        amountBtc: amountBtc,
        amountUsd: amountUsd,
        btcPriceAtTime: btcPriceAtTime,
        fromAddress: fromAddress,
        toAddress: toAddress,
      );
      return Right(transaction);
    } on TransactionException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
