import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/core/network/dio_client.dart';
import 'package:crypto_wallet/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_wallet/features/market/data/repositories/market_repository_impl.dart';
import 'package:crypto_wallet/features/market/data/datasources/market_datasource.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';

/// Dio client provider for market datasource
final marketDioProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Market datasource provider
final marketDatasourceProvider = Provider<MarketDatasource>((ref) {
  final dioClient = ref.watch(marketDioProvider);
  return CoinGeckoDatasource(dioClient.dio);
});

/// Market repository provider
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final datasource = ref.watch(marketDatasourceProvider);
  return MarketRepositoryImpl(datasource);
});

/// BTC Price stream provider
/// Polls CoinGecko API every 30 seconds
final btcPriceStreamProvider = StreamProvider<BtcPriceEntity>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getBtcPriceStream().map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (price) => price,
    );
  });
});

/// BTC Price provider (latest value)
final btcPriceProvider = Provider<BtcPriceEntity?>((ref) {
  final btcPriceAsync = ref.watch(btcPriceStreamProvider);
  return btcPriceAsync.value;
});

/// BTC Price loading state provider
final btcPriceLoadingProvider = Provider<bool>((ref) {
  final btcPriceAsync = ref.watch(btcPriceStreamProvider);
  return btcPriceAsync.isLoading;
});

/// BTC Price error provider
final btcPriceErrorProvider = Provider<String?>((ref) {
  final btcPriceAsync = ref.watch(btcPriceStreamProvider);
  return btcPriceAsync.error?.toString();
});
