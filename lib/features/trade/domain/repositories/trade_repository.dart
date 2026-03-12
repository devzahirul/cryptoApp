import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';

/// Trade repository for buy/sell operations
abstract class TradeRepository {
  /// Buy BTC with USD
  Future<Either<Failure, (double btcAmount, TransactionEntity transaction)>> buyBtc({
    required double usdAmount,
    required double btcPrice,
  });

  /// Sell BTC for USD
  Future<Either<Failure, (double usdAmount, TransactionEntity transaction)>> sellBtc({
    required double btcAmount,
    required double btcPrice,
  });
}
