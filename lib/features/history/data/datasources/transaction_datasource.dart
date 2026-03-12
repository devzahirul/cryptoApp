import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';

/// Data source for transaction operations
abstract class TransactionDatasource {
  /// Get transaction history for current user
  Future<List<TransactionEntity>> getTransactions({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  });

  /// Create a new transaction
  Future<TransactionEntity> createTransaction({
    required TransactionType type,
    required double amountBtc,
    double? amountUsd,
    double? btcPriceAtTime,
    String? fromAddress,
    String? toAddress,
    TransactionStatus? status,
  });

  /// Get a single transaction by ID
  Future<TransactionEntity> getTransaction(String transactionId);

  /// Update transaction status
  Future<TransactionEntity> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
  });
}

/// Supabase implementation of TransactionDatasource
class SupabaseTransactionDatasource implements TransactionDatasource {
  final SupabaseClient client;

  SupabaseTransactionDatasource({required this.client});

  @override
  Future<List<TransactionEntity>> getTransactions({
    int page = 0,
    int limit = 20,
    TransactionType? type,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransactionException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      var query = client
          .from('transactions')
          .select()
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('type', type.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((data) => _toTransactionEntity(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw TransactionException(
        message: 'Failed to fetch transactions',
        code: 'fetch_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionEntity> createTransaction({
    required TransactionType type,
    required double amountBtc,
    double? amountUsd,
    double? btcPriceAtTime,
    String? fromAddress,
    String? toAddress,
    TransactionStatus? status,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransactionException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final response = await client.from('transactions').insert({
        'user_id': userId,
        'type': type.name,
        'amount_btc': amountBtc,
        'amount_usd': amountUsd,
        'btc_price_at_time': btcPriceAtTime,
        'from_address': fromAddress,
        'to_address': toAddress,
        'status': (status ?? TransactionStatus.completed).name,
      }).select().single();

      return _toTransactionEntity(response);
    } catch (e) {
      throw TransactionException(
        message: 'Failed to create transaction',
        code: 'create_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionEntity> getTransaction(String transactionId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransactionException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final response = await client
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .eq('user_id', userId)
          .single();

      return _toTransactionEntity(response);
    } catch (e) {
      throw TransactionException(
        message: 'Failed to fetch transaction',
        code: 'fetch_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionEntity> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransactionException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final response = await client
          .from('transactions')
          .update({'status': status.name})
          .eq('id', transactionId)
          .eq('user_id', userId)
          .select()
          .single();

      return _toTransactionEntity(response);
    } catch (e) {
      throw TransactionException(
        message: 'Failed to update transaction',
        code: 'update_failed',
        originalError: e,
      );
    }
  }

  /// Convert Map to TransactionEntity
  TransactionEntity _toTransactionEntity(Map<String, dynamic> data) {
    return TransactionEntity(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.buy,
      ),
      amountBtc: data['amount_btc'] != null
          ? (data['amount_btc'] as num).toDouble()
          : null,
      amountUsd: data['amount_usd'] != null
          ? (data['amount_usd'] as num).toDouble()
          : null,
      btcPriceAtTime: data['btc_price_at_time'] != null
          ? (data['btc_price_at_time'] as num).toDouble()
          : null,
      fromAddress: data['from_address'] as String?,
      toAddress: data['to_address'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}

/// Transaction exception
class TransactionException extends AppException {
  const TransactionException({
    required super.message,
    super.code,
    super.originalError,
  });
}
