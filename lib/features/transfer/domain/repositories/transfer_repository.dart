import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/transfer/data/datasources/transfer_datasource.dart';

/// Abstract repository for transfer operations
abstract class TransferRepository {
  /// Send BTC to another wallet address
  Future<Either<Failure, SendResult>> sendBtc({
    required String recipientAddress,
    required double btcAmount,
  });

  /// Get receive address for current user
  Future<Either<Failure, String>> getReceiveAddress();

  /// Check if an address belongs to an internal user
  Future<Either<Failure, bool>> isInternalAddress(String address);
}
