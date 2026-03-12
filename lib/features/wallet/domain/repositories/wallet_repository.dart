import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Abstract repository for wallet operations
abstract class WalletRepository {
  /// Get wallet for current user
  Future<Either<Failure, WalletEntity>> getWallet();

  /// Update wallet balances
  Future<Either<Failure, WalletEntity>> updateBalances({
    double? usdBalance,
    double? btcBalance,
  });

  /// Generate a new BTC address (mock for MVP)
  Future<Either<Failure, String>> generateBtcAddress();
}
