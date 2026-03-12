import 'package:equatable/equatable.dart';

/// Wallet entity representing user's crypto wallet
class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final double usdBalance;
  final double btcBalance;
  final String btcAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.usdBalance,
    required this.btcBalance,
    required this.btcAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total value in USD (USD balance + BTC balance * BTC price)
  double getTotalValueUsd(double btcPrice) {
    return usdBalance + (btcBalance * btcPrice);
  }

  /// Create copy with updated fields
  WalletEntity copyWith({
    String? id,
    String? userId,
    double? usdBalance,
    double? btcBalance,
    String? btcAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      usdBalance: usdBalance ?? this.usdBalance,
      btcBalance: btcBalance ?? this.btcBalance,
      btcAddress: btcAddress ?? this.btcAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        usdBalance,
        btcBalance,
        btcAddress,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'WalletEntity(id: $id, userId: $userId, btcBalance: $btcBalance, usdBalance: $usdBalance)';
  }
}
