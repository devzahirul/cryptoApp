import 'package:equatable/equatable.dart';

/// Transaction entity representing a crypto transaction
class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double? amountBtc;
  final double? amountUsd;
  final double? btcPriceAtTime;
  final String? fromAddress;
  final String? toAddress;
  final TransactionStatus status;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.amountBtc,
    this.amountUsd,
    this.btcPriceAtTime,
    this.fromAddress,
    this.toAddress,
    required this.status,
    required this.createdAt,
  });

  /// Get transaction icon based on type
  String get icon {
    switch (type) {
      case TransactionType.buy:
        return 'arrow_downward';
      case TransactionType.sell:
        return 'arrow_upward';
      case TransactionType.send:
        return 'send';
      case TransactionType.receive:
        return 'download';
    }
  }

  /// Get transaction color based on type
  String get color {
    switch (type) {
      case TransactionType.buy:
      case TransactionType.receive:
        return 'success';
      case TransactionType.sell:
      case TransactionType.send:
        return 'danger';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amountBtc,
        amountUsd,
        btcPriceAtTime,
        fromAddress,
        toAddress,
        status,
        createdAt,
      ];
}

/// Transaction type enum
enum TransactionType {
  buy,
  sell,
  send,
  receive,
}

/// Transaction status enum
enum TransactionStatus {
  pending,
  completed,
  failed,
}

/// Extension for displaying transaction type
extension TransactionTypeX on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.send:
        return 'Send';
      case TransactionType.receive:
        return 'Receive';
    }
  }
}

/// Extension for displaying transaction status
extension TransactionStatusX on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}
