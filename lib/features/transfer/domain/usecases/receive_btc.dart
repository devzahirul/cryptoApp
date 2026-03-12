import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/transfer/domain/repositories/transfer_repository.dart';

/// Use case for receiving BTC (getting receive address)
class ReceiveBtcUseCase {
  final TransferRepository repository;

  ReceiveBtcUseCase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.getReceiveAddress();
  }
}
