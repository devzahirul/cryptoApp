import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';

/// Data source for trade operations
abstract class TradeDatasource {
  /// Buy BTC with USD
  /// Returns updated wallet and created transaction
  Future<(WalletEntity, TransactionEntity)> buyBtc({
    required double usdAmount,
    required double btcPrice,
  });

  /// Sell BTC for USD
  /// Returns updated wallet and created transaction
  Future<(WalletEntity, TransactionEntity)> sellBtc({
    required double btcAmount,
    required double btcPrice,
  });
}

/// Supabase implementation of TradeDatasource
class SupabaseTradeDatasource implements TradeDatasource {
  final SupabaseClient client;

  SupabaseTradeDatasource({required this.client});

  @override
  Future<(WalletEntity, TransactionEntity)> buyBtc({
    required double usdAmount,
    required double btcPrice,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TradeException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Calculate BTC amount
      final btcAmount = usdAmount / btcPrice;

      // Use Supabase transaction for atomic update
      final result = await client.rpc('buy_btc', params: {
        'p_user_id': userId,
        'p_usd_amount': usdAmount,
        'p_btc_amount': btcAmount,
        'p_btc_price': btcPrice,
      });

      // Parse the result
      final walletData = result['wallet'] as Map<String, dynamic>;
      final transactionData = result['transaction'] as Map<String, dynamic>;

      final wallet = _toWalletEntity(walletData);
      final transaction = _toTransactionEntity(transactionData);

      return (wallet, transaction);
    } on PostgrestException catch (e) {
      // Check for insufficient funds error
      if (e.message.contains('Insufficient USD balance')) {
        throw const TradeException(
          message: 'Insufficient USD balance',
          code: 'insufficient_funds',
        );
      }
      throw TradeException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw TradeException(
        message: 'Failed to buy BTC',
        code: 'buy_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<(WalletEntity, TransactionEntity)> sellBtc({
    required double btcAmount,
    required double btcPrice,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const TradeException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Calculate USD amount
      final usdAmount = btcAmount * btcPrice;

      // Use Supabase transaction for atomic update
      final result = await client.rpc('sell_btc', params: {
        'p_user_id': userId,
        'p_btc_amount': btcAmount,
        'p_usd_amount': usdAmount,
        'p_btc_price': btcPrice,
      });

      // Parse the result
      final walletData = result['wallet'] as Map<String, dynamic>;
      final transactionData = result['transaction'] as Map<String, dynamic>;

      final wallet = _toWalletEntity(walletData);
      final transaction = _toTransactionEntity(transactionData);

      return (wallet, transaction);
    } on PostgrestException catch (e) {
      // Check for insufficient funds error
      if (e.message.contains('Insufficient BTC balance')) {
        throw const TradeException(
          message: 'Insufficient BTC balance',
          code: 'insufficient_funds',
        );
      }
      throw TradeException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw TradeException(
        message: 'Failed to sell BTC',
        code: 'sell_failed',
        originalError: e,
      );
    }
  }

  /// Convert Map to WalletEntity
  WalletEntity _toWalletEntity(Map<String, dynamic> data) {
    return WalletEntity(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      usdBalance: (data['usd_balance'] as num).toDouble(),
      btcBalance: (data['btc_balance'] as num).toDouble(),
      btcAddress: data['btc_address'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
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
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}

/// Trade exception
class TradeException extends AppException {
  const TradeException({
    required super.message,
    super.code,
    super.originalError,
  });
}
