import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/features/market/domain/entities/btc_price_entity.dart';

/// Price ticker widget displaying live BTC price
class PriceTickerWidget extends StatelessWidget {
  final BtcPriceEntity? price;
  final bool isLoading;
  final String? error;

  const PriceTickerWidget({
    super.key,
    this.price,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingPriceTicker();
    }

    if (error != null) {
      return _ErrorPriceTicker(message: error!);
    }

    if (price == null) {
      return const _EmptyPriceTicker();
    }

    return _PriceDisplay(price: price!);
  }
}

class _LoadingPriceTicker extends StatelessWidget {
  const _LoadingPriceTicker();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'BTC/USD',
          style: TextStyle(
            fontSize: AppSizes.textSubhead,
            fontWeight: FontWeight.w500,
            color: AppColors.secondLabel,
          ),
        ),
        const SizedBox(width: AppSizes.spacing8),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondLabel),
          ),
        ),
      ],
    );
  }
}

class _ErrorPriceTicker extends StatelessWidget {
  final String message;

  const _ErrorPriceTicker({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          size: 16,
          color: AppColors.danger,
        ),
        const SizedBox(width: AppSizes.spacing8),
        Flexible(
          child: Text(
            'Price unavailable',
            style: TextStyle(
              fontSize: AppSizes.textSubhead,
              fontWeight: FontWeight.w500,
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPriceTicker extends StatelessWidget {
  const _EmptyPriceTicker();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'BTC/USD',
      style: TextStyle(
        fontSize: AppSizes.textSubhead,
        fontWeight: FontWeight.w500,
        color: AppColors.secondLabel,
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final BtcPriceEntity price;

  const _PriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    final isUp = price.isUp;
    final changeColor = isUp ? AppColors.success : AppColors.danger;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BTC/USD',
              style: TextStyle(
                fontSize: AppSizes.textFootnote,
                fontWeight: FontWeight.w500,
                color: AppColors.secondLabel,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${price.priceUsd.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: AppSizes.textTitle2,
                fontWeight: FontWeight.w700,
                color: AppColors.label,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing8,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            color: changeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${isUp ? '+' : ''}${price.percentChange24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: AppSizes.textFootnote,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
