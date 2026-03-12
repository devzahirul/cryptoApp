import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';

/// Abstract repository for market data operations
abstract class MarketRepository {
  /// Get current BTC price
  Future<Either<Failure, BtcPriceEntity>> getBtcPrice();

  /// Stream of BTC price updates
  Stream<Either<Failure, BtcPriceEntity>> getBtcPriceStream();
}
