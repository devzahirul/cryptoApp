import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/features/trade/data/datasources/trade_datasource.dart';
import 'package:crypto_wallet/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:crypto_wallet/features/trade/domain/repositories/trade_repository.dart';
import 'package:crypto_wallet/features/trade/domain/usecases/buy_btc.dart';
import 'package:crypto_wallet/features/trade/domain/usecases/sell_btc.dart';
import 'package:crypto_wallet/shared/providers/supabase_provider.dart';
import 'package:crypto_wallet/features/market/presentation/providers/btc_price_provider.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';

/// Trade datasource provider
final tradeDatasourceProvider = Provider<TradeDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTradeDatasource(client: supabase);
});

/// Trade repository provider
final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  final datasource = ref.watch(tradeDatasourceProvider);
  return TradeRepositoryImpl(datasource);
});

/// Buy BTC use case provider
final buyBtcUseCaseProvider = Provider<BuyBtcUseCase>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return BuyBtcUseCase(repository);
});

/// Sell BTC use case provider
final sellBtcUseCaseProvider = Provider<SellBtcUseCase>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return SellBtcUseCase(repository);
});

/// Trade notifier provider
/// Manages buy/sell state and operations
final tradeNotifierProvider = NotifierProvider<TradeNotifier, TradeState>(() {
  return TradeNotifier();
});

/// Trade state
class TradeState {
  final bool isLoading;
  final String? error;
  final double? lastBtcAmount;
  final double? lastUsdAmount;

  const TradeState({
    this.isLoading = false,
    this.error,
    this.lastBtcAmount,
    this.lastUsdAmount,
  });

  TradeState copyWith({
    bool? isLoading,
    String? error,
    double? lastBtcAmount,
    double? lastUsdAmount,
  }) {
    return TradeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastBtcAmount: lastBtcAmount ?? this.lastBtcAmount,
      lastUsdAmount: lastUsdAmount ?? this.lastUsdAmount,
    );
  }
}

/// Trade notifier
class TradeNotifier extends Notifier<TradeState> {
  @override
  TradeState build() {
    return const TradeState();
  }

  /// Buy BTC with USD
  Future<bool> buyBtc({
    required double usdAmount,
    required double btcPrice,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(buyBtcUseCaseProvider);
      final result = await useCase(
        usdAmount: usdAmount,
        btcPrice: btcPrice,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (data) {
          final (btcAmount, transaction) = data;
          state = state.copyWith(
            isLoading: false,
            lastBtcAmount: btcAmount,
            lastUsdAmount: usdAmount,
          );
          // Invalidate wallet provider to refresh balance
          ref.invalidate(userWalletProvider);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sell BTC for USD
  Future<bool> sellBtc({
    required double btcAmount,
    required double btcPrice,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(sellBtcUseCaseProvider);
      final result = await useCase(
        btcAmount: btcAmount,
        btcPrice: btcPrice,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (data) {
          final (usdAmount, transaction) = data;
          state = state.copyWith(
            isLoading: false,
            lastBtcAmount: btcAmount,
            lastUsdAmount: usdAmount,
          );
          // Invalidate wallet provider to refresh balance
          ref.invalidate(userWalletProvider);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear state
  void clear() {
    state = const TradeState();
  }
}
