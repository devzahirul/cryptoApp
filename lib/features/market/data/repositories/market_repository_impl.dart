import 'package:dartz/dartz.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart' as app_exceptions;
import 'package:crypto_wallet/core/errors/failures.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';
import 'package:crypto_wallet/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_wallet/features/market/data/datasources/market_datasource.dart';

/// Implementation of MarketRepository
class MarketRepositoryImpl implements MarketRepository {
  final MarketDatasource datasource;

  MarketRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, BtcPriceEntity>> getBtcPrice() async {
    try {
      final price = await datasource.getBtcPrice();
      return Right(price);
    } on app_exceptions.ApiException catch (e) {
      return Left(ApiFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, BtcPriceEntity>> getBtcPriceStream() async* {
    try {
      await for (final price in datasource.getBtcPriceStream()) {
        yield Right(price);
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }
}
