import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/features/history/domain/repositories/transaction_repository.dart';

/// Use case for getting transaction history
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  }) {
    return repository.getTransactions(
      page: page,
      limit: limit,
      type: type,
    );
  }
}
