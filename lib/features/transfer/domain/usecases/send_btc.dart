import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/transfer/data/datasources/transfer_datasource.dart';
import 'package:crypto_wallet/features/transfer/domain/repositories/transfer_repository.dart';

/// Use case for sending BTC
class SendBtcUseCase {
  final TransferRepository repository;

  SendBtcUseCase(this.repository);

  Future<Either<Failure, SendResult>> call({
    required String recipientAddress,
    required double btcAmount,
  }) {
    return repository.sendBtc(
      recipientAddress: recipientAddress,
      btcAmount: btcAmount,
    );
  }
}
