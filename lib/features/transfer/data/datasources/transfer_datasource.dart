import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';

/// Data source for transfer operations
abstract class TransferDatasource {
  /// Send BTC to another wallet address
  Future<SendResult> sendBtc({
    required String recipientAddress,
    required double btcAmount,
  });

  /// Generate receive address for current user
  Future<String> getReceiveAddress();

  /// Check if an address belongs to an internal user
  Future<bool> isInternalAddress(String address);
}

/// Send result
class SendResult {
  final TransactionEntity senderTransaction;
  final TransactionEntity? recipientTransaction;
  final bool isInternalTransfer;

  SendResult({
    required this.senderTransaction,
    this.recipientTransaction,
    required this.isInternalTransfer,
  });
}

/// Supabase implementation of TransferDatasource
class SupabaseTransferDatasource implements TransferDatasource {
  final SupabaseClient client;

  SupabaseTransferDatasource({required this.client});

  @override
  Future<SendResult> sendBtc({
    required String recipientAddress,
    required double btcAmount,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransferException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Call the RPC function
      final result = await client.rpc('send_btc', params: {
        'p_sender_id': userId,
        'p_recipient_address': recipientAddress,
        'p_btc_amount': btcAmount,
      });

      // Parse the result
      final isInternal = result['is_internal_transfer'] as bool;
      final senderTxId = result['sender_tx_id'] as String;
      final recipientTxId = result['recipient_tx_id'] as String?;

      // Fetch the full transaction records
      final senderTx = await _getTransaction(senderTxId);

      TransactionEntity? recipientTx;
      if (recipientTxId != null) {
        recipientTx = await _getTransaction(recipientTxId);
      }

      return SendResult(
        senderTransaction: senderTx,
        recipientTransaction: recipientTx,
        isInternalTransfer: isInternal,
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('Insufficient BTC balance')) {
        throw const TransferException(
          message: 'Insufficient BTC balance',
          code: 'insufficient_funds',
        );
      }
      if (e.message.contains('Sender wallet not found')) {
        throw const TransferException(
          message: 'Wallet not found',
          code: 'wallet_not_found',
        );
      }
      throw TransferException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw TransferException(
        message: 'Failed to send BTC',
        code: 'send_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<String> getReceiveAddress() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TransferException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final response = await client
          .from('wallets')
          .select('btc_address')
          .eq('user_id', userId)
          .single();

      return response['btc_address'] as String;
    } catch (e) {
      throw TransferException(
        message: 'Failed to get receive address',
        code: 'fetch_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> isInternalAddress(String address) async {
    try {
      final response = await client
          .from('wallets')
          .select('id')
          .eq('btc_address', address)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw TransferException(
        message: 'Failed to validate address',
        code: 'validation_failed',
        originalError: e,
      );
    }
  }

  /// Fetch a transaction by ID
  Future<TransactionEntity> _getTransaction(String id) async {
    final response = await client
        .from('transactions')
        .select()
        .eq('id', id)
        .single();

    return _toTransactionEntity(response);
  }

  /// Convert Map to TransactionEntity
  TransactionEntity _toTransactionEntity(Map<String, dynamic> data) {
    return TransactionEntity(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.send,
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
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}

/// Transfer exception
class TransferException extends AppException {
  const TransferException({
    required super.message,
    super.code,
    super.originalError,
  });
}
