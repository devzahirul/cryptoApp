import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/features/transfer/data/datasources/transfer_datasource.dart';
import 'package:crypto_wallet/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:crypto_wallet/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:crypto_wallet/features/transfer/domain/usecases/send_btc.dart';
import 'package:crypto_wallet/features/transfer/domain/usecases/receive_btc.dart';
import 'package:crypto_wallet/shared/providers/supabase_provider.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';

/// Transfer datasource provider
final transferDatasourceProvider = Provider<TransferDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTransferDatasource(client: supabase);
});

/// Transfer repository provider
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final datasource = ref.watch(transferDatasourceProvider);
  return TransferRepositoryImpl(datasource);
});

/// Send BTC use case provider
final sendBtcUseCaseProvider = Provider<SendBtcUseCase>((ref) {
  final repository = ref.watch(transferRepositoryProvider);
  return SendBtcUseCase(repository);
});

/// Receive BTC use case provider
final receiveBtcUseCaseProvider = Provider<ReceiveBtcUseCase>((ref) {
  final repository = ref.watch(transferRepositoryProvider);
  return ReceiveBtcUseCase(repository);
});

/// Receive address provider
/// Fetches the current user's BTC receive address
final receiveAddressProvider = FutureProvider<String>((ref) async {
  final useCase = ref.read(receiveBtcUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (address) => address,
  );
});

/// Transfer notifier provider
/// Manages send state and operations
final transferNotifierProvider = NotifierProvider<TransferNotifier, TransferState>(() {
  return TransferNotifier();
});

/// Transfer state
class TransferState {
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String? successMessage;
  final String? recipientAddress;
  final double? amount;

  const TransferState({
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.successMessage,
    this.recipientAddress,
    this.amount,
  });

  TransferState copyWith({
    bool? isLoading,
    bool? isSending,
    String? error,
    String? successMessage,
    String? recipientAddress,
    double? amount,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      successMessage: successMessage,
      recipientAddress: recipientAddress,
      amount: amount,
    );
  }
}

/// Transfer notifier
class TransferNotifier extends Notifier<TransferState> {
  @override
  TransferState build() {
    return const TransferState();
  }

  /// Send BTC to a recipient address
  Future<bool> sendBtc({
    required String recipientAddress,
    required double btcAmount,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final useCase = ref.read(sendBtcUseCaseProvider);
      final result = await useCase(
        recipientAddress: recipientAddress,
        btcAmount: btcAmount,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isSending: false,
            error: failure.message,
          );
          return false;
        },
        (sendResult) {
          state = state.copyWith(
            isSending: false,
            successMessage: sendResult.isInternalTransfer
                ? 'Sent $btcAmount BTC successfully'
                : 'Sent $btcAmount BTC to external address',
            recipientAddress: recipientAddress,
            amount: btcAmount,
          );
          // Invalidate wallet provider to refresh balance
          ref.invalidate(userWalletProvider);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Load receive address
  Future<void> loadReceiveAddress() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final address = await ref.read(receiveAddressProvider.future);
      state = state.copyWith(
        isLoading: false,
        recipientAddress: address,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear state
  void clear() {
    state = const TransferState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
