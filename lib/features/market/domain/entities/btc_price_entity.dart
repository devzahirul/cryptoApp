import 'package:equatable/equatable.dart';

/// BTC Price entity from CoinGecko API
class BtcPriceEntity extends Equatable {
  final double priceUsd;
  final double percentChange24h;
  final DateTime lastUpdated;

  const BtcPriceEntity({
    required this.priceUsd,
    required this.percentChange24h,
    required this.lastUpdated,
  });

  /// Check if price went up
  bool get isUp => percentChange24h > 0;

  /// Check if price went down
  bool get isDown => percentChange24h < 0;

  /// Format price as USD string
  String get priceString => '\$${priceUsd.toStringAsFixed(2)}';

  /// Format percent change with sign and color indicator
  String get percentChangeString {
    final sign = isUp ? '+' : '';
    return '$sign${percentChange24h.toStringAsFixed(2)}%';
  }

  /// Create copy with updated fields
  BtcPriceEntity copyWith({
    double? priceUsd,
    double? percentChange24h,
    DateTime? lastUpdated,
  }) {
    return BtcPriceEntity(
      priceUsd: priceUsd ?? this.priceUsd,
      percentChange24h: percentChange24h ?? this.percentChange24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [priceUsd, percentChange24h, lastUpdated];

  @override
  String toString() {
    return 'BtcPriceEntity(price: \$${priceUsd.toStringAsFixed(2)}, change: ${percentChange24h.toStringAsFixed(2)}%)';
  }
}
