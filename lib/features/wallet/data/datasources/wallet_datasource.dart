import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_wallet/core/errors/exceptions.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';

/// Data source for wallet operations
abstract class WalletDatasource {
  /// Get wallet for current user
  Future<WalletEntity> getWallet();

  /// Update wallet balances
  Future<WalletEntity> updateBalances({
    double? usdBalance,
    double? btcBalance,
  });

  /// Generate a new BTC address (mock for MVP)
  Future<String> generateBtcAddress();

  /// Get wallet with current BTC price
  Future<(WalletEntity, BtcPriceEntity)> getWalletWithPrice();
}

/// Supabase implementation of WalletDatasource
class SupabaseWalletDatasource implements WalletDatasource {
  final SupabaseClient client;
  final String Function() _generateMockAddress;

  SupabaseWalletDatasource({
    required this.client,
    required String Function() generateMockAddress,
  }) : _generateMockAddress = generateMockAddress;

  @override
  Future<WalletEntity> getWallet() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const WalletException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final response = await client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();

      return _toWalletEntity(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No wallet found, create one
        final userId = client.auth.currentUser?.id;
        return await _createWallet(userId!);
      }
      throw WalletException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw WalletException(
        message: 'Failed to fetch wallet',
        code: 'fetch_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<WalletEntity> updateBalances({
    double? usdBalance,
    double? btcBalance,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw const WalletException(
          message: 'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (usdBalance != null) {
        updates['usd_balance'] = usdBalance;
      }
      if (btcBalance != null) {
        updates['btc_balance'] = btcBalance;
      }

      final response = await client
          .from('wallets')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return _toWalletEntity(response);
    } catch (e) {
      throw WalletException(
        message: 'Failed to update wallet',
        code: 'update_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<String> generateBtcAddress() async {
    // Mock BTC address generation for MVP
    // In production, this would integrate with a real wallet service
    return _generateMockAddress();
  }

  @override
  Future<(WalletEntity, BtcPriceEntity)> getWalletWithPrice() async {
    final wallet = await getWallet();
    // For now, return a placeholder price
    // In production, this would fetch from market datasource
    final price = BtcPriceEntity(
      priceUsd: 0,
      percentChange24h: 0,
      lastUpdated: DateTime.now(),
    );
    return (wallet, price);
  }

  /// Create a new wallet for user
  Future<WalletEntity> _createWallet(String userId) async {
    try {
      final btcAddress = await generateBtcAddress();

      final response = await client.from('wallets').insert({
        'user_id': userId,
        'usd_balance': 0,
        'btc_balance': 0,
        'btc_address': btcAddress,
      }).select().single();

      return _toWalletEntity(response);
    } catch (e) {
      throw WalletException(
        message: 'Failed to create wallet',
        code: 'create_failed',
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
}

/// Generate random mock BTC address
String generateMockBtcAddress() {
  const chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  final random = Random();
  final address = List.generate(34, (i) {
    if (i == 0) return '1'; // Mainnet addresses start with 1
    return chars[random.nextInt(chars.length)];
  }).join();
  return address;
}

/// Wallet exception
class WalletException extends AppException {
  const WalletException({
    required super.message,
    super.code,
    super.originalError,
  });
}
