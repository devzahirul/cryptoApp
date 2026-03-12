import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/shared/providers/supabase_provider.dart';
import 'package:crypto_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:crypto_wallet/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:crypto_wallet/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Wallet datasource provider
final walletDatasourceProvider = Provider<WalletDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseWalletDatasource(
    client: supabase,
    generateMockAddress: generateMockBtcAddress,
  );
});

/// Wallet repository provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final datasource = ref.watch(walletDatasourceProvider);
  return WalletRepositoryImpl(datasource);
});

/// User wallet provider
/// Fetches the current user's wallet
final userWalletProvider = FutureProvider<WalletEntity>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final result = await repository.getWallet();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (wallet) => wallet,
  );
});

/// Wallet refresher provider
/// Allows manual refresh of wallet data
final walletRefresherProvider = Provider<WalletRefresher>((ref) {
  return WalletRefresher(ref);
});

/// Wallet refresher class
class WalletRefresher {
  final Ref _ref;

  WalletRefresher(this._ref);

  void refresh() {
    _ref.invalidate(userWalletProvider);
  }
}
