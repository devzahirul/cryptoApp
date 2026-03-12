import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/core/constants/app_strings.dart';
import 'package:crypto_wallet/core/extensions/build_context_extensions.dart';
import 'package:crypto_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Balance card widget displaying wallet balance
class BalanceCardWidget extends StatelessWidget {
  final WalletEntity wallet;
  final double btcPrice;
  final VoidCallback? onTap;

  const BalanceCardWidget({
    super.key,
    required this.wallet,
    required this.btcPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = wallet.getTotalValueUsd(btcPrice);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.btcGradientStart, AppColors.btcGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.balanceCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.btcOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total value label
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: AppSizes.textFootnote,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),

          // Total value in USD
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: AppSizes.textTitle2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spacing24),

          // BTC and USD balances row
          Row(
            children: [
              // BTC Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BTC',
                      style: TextStyle(
                        fontSize: AppSizes.textFootnote,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wallet.btcBalance.toStringAsFixed(8)}',
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // USD Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USD',
                      style: TextStyle(
                        fontSize: AppSizes.textFootnote,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${wallet.usdBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick actions row widget
class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onBuy;
  final VoidCallback? onSell;
  final VoidCallback? onSend;
  final VoidCallback? onReceive;

  const QuickActionsRow({
    super.key,
    this.onBuy,
    this.onSell,
    this.onSend,
    this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionButton(
          icon: Icons.add_circle_outline,
          label: 'Buy',
          color: AppColors.success,
          onTap: onBuy,
        ),
        _QuickActionButton(
          icon: Icons.remove_circle_outline,
          label: 'Sell',
          color: AppColors.danger,
          onTap: onSell,
        ),
        _QuickActionButton(
          icon: Icons.send_outlined,
          label: 'Send',
          color: AppColors.primary,
          onTap: onSend,
        ),
        _QuickActionButton(
          icon: Icons.qr_code_2_outlined,
          label: 'Receive',
          color: AppColors.warning,
          onTap: onReceive,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing12,
          vertical: AppSizes.spacing8,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppSizes.iconMedium,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.textFootnote,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// BTC Address display widget
class BtcAddressWidget extends StatelessWidget {
  final String address;

  const BtcAddressWidget({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: address));
        context.showSnackBar(AppStrings.addressCopied);
      },
      borderRadius: BorderRadius.circular(AppSizes.radius8),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing12),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: AppColors.secondLabel,
            ),
            const SizedBox(width: AppSizes.spacing8),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: AppSizes.textFootnote,
                  color: AppColors.secondLabel,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSizes.spacing8),
            const Icon(
              Icons.copy,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
