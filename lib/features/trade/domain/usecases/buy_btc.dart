import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/trade/domain/repositories/trade_repository.dart';

/// Use case for buying BTC with USD
class BuyBtcUseCase {
  final TradeRepository repository;

  BuyBtcUseCase(this.repository);

  Future<Either<Failure, (double btcAmount, dynamic transaction)>> call({
    required double usdAmount,
    required double btcPrice,
  }) {
    return repository.buyBtc(
      usdAmount: usdAmount,
      btcPrice: btcPrice,
    );
  }
}
