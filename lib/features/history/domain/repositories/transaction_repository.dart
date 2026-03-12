import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';

/// Abstract repository for transaction history operations
abstract class TransactionRepository {
  /// Get transaction history for current user
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  });

  /// Create a new transaction
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required TransactionType type,
    required double amountBtc,
    double? amountUsd,
    double? btcPriceAtTime,
    String? fromAddress,
    String? toAddress,
  });
}
