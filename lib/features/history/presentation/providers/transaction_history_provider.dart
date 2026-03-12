import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/features/history/data/datasources/transaction_datasource.dart';
import 'package:crypto_wallet/features/history/data/repositories/transaction_repository_impl.dart';
import 'package:crypto_wallet/features/history/domain/repositories/transaction_repository.dart';
import 'package:crypto_wallet/features/history/domain/usecases/get_transactions.dart';
import 'package:crypto_wallet/features/history/domain/usecases/create_transaction.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/shared/providers/supabase_provider.dart';

/// Transaction datasource provider
final transactionDatasourceProvider = Provider<TransactionDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTransactionDatasource(client: supabase);
});

/// Transaction repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final datasource = ref.watch(transactionDatasourceProvider);
  return TransactionRepositoryImpl(datasource);
});

/// Get transactions use case provider
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repository);
});

/// Create transaction use case provider
final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return CreateTransactionUseCase(repository);
});

/// Transaction history stream provider
/// Watches transaction history with pagination and optional filtering
final transactionHistoryStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final datasource = ref.watch(transactionDatasourceProvider);

  // For now, return a simple stream that fetches on demand
  // In production, this could use Supabase realtime subscriptions
  return Stream.fromFuture(datasource.getTransactions(page: 0, limit: 50));
});

/// Transaction history provider (Notifier)
/// Manages transaction history state with filtering and pagination
final transactionHistoryNotifierProvider = NotifierProvider<TransactionHistoryNotifier, List<TransactionEntity>>(() {
  return TransactionHistoryNotifier();
});

class TransactionHistoryNotifier extends Notifier<List<TransactionEntity>> {
  @override
  List<TransactionEntity> build() {
    return [];
  }

  /// Load transaction history
  Future<void> loadTransactions({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  }) async {
    state = []; // Clear current state

    final datasource = ref.read(transactionDatasourceProvider);
    try {
      final transactions = await datasource.getTransactions(
        page: page,
        limit: limit,
        type: type,
      );
      state = transactions;
    } catch (e) {
      // Handle error silently - UI can use AsyncValue for error state
      state = [];
    }
  }

  /// Add a transaction to the list (optimistic update)
  void addTransaction(TransactionEntity transaction) {
    state = [transaction, ...state];
  }

  /// Filter transactions by type
  List<TransactionEntity> filterByType(TransactionType type) {
    return state.where((t) => t.type == type).toList();
  }
}
