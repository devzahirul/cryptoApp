import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/features/history/domain/repositories/transaction_repository.dart';

/// Use case for creating a new transaction
class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required TransactionType type,
    required double amountBtc,
    double? amountUsd,
    double? btcPriceAtTime,
    String? fromAddress,
    String? toAddress,
  }) {
    return repository.createTransaction(
      type: type,
      amountBtc: amountBtc,
      amountUsd: amountUsd,
      btcPriceAtTime: btcPriceAtTime,
      fromAddress: fromAddress,
      toAddress: toAddress,
    );
  }
}
