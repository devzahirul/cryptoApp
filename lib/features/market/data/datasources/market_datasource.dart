import 'package:dio/dio.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';

/// Data source for market data operations
/// Handles direct CoinGecko API calls
abstract class MarketDatasource {
  /// Get current BTC price
  Future<BtcPriceEntity> getBtcPrice();

  /// Stream of BTC price updates
  Stream<BtcPriceEntity> getBtcPriceStream();
}

/// CoinGecko implementation of MarketDatasource
class CoinGeckoDatasource implements MarketDatasource {
  final Dio dio;

  CoinGeckoDatasource(this.dio);

  @override
  Future<BtcPriceEntity> getBtcPrice() async {
    try {
      final response = await dio.get(
        '/simple/price',
        queryParameters: {
          'ids': 'bitcoin',
          'vs_currencies': 'usd',
          'include_24hr_change': 'true',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final btcData = data['bitcoin'] as Map<String, dynamic>;

      return BtcPriceEntity(
        priceUsd: (btcData['usd'] as num).toDouble(),
        percentChange24h: (btcData['usd_24h_change'] as num).toDouble(),
        lastUpdated: DateTime.now(),
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'Failed to fetch BTC price',
        statusCode: e.response?.statusCode,
        code: 'price_fetch_failed',
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred while fetching BTC price',
        code: 'unknown',
        originalError: e,
      );
    }
  }

  @override
  Stream<BtcPriceEntity> getBtcPriceStream() {
    return Stream.periodic(const Duration(seconds: 30), (_) => _)
        .asyncMap((_) => getBtcPrice());
  }
}
