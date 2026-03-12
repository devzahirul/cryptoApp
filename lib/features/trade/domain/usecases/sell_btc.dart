import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/trade/domain/repositories/trade_repository.dart';

/// Use case for selling BTC for USD
class SellBtcUseCase {
  final TradeRepository repository;

  SellBtcUseCase(this.repository);

  Future<Either<Failure, (double usdAmount, dynamic transaction)>> call({
    required double btcAmount,
    required double btcPrice,
  }) {
    return repository.sellBtc(
      btcAmount: btcAmount,
      btcPrice: btcPrice,
    );
  }
}
