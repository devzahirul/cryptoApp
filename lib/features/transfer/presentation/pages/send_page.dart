import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/shared/widgets/app_button.dart';
import 'package:crypto_wallet/shared/widgets/app_text_field.dart';
import 'package:crypto_wallet/shared/widgets/app_card.dart';
import 'package:crypto_wallet/features/transfer/presentation/providers/transfer_provider.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:crypto_wallet/features/market/presentation/providers/btc_price_provider.dart';

/// Send BTC page
class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(userWalletProvider);
    final transferState = ref.watch(transferNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send BTC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wallet balance
              walletAsync.when(
                data: (wallet) => AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BTC Balance',
                          style: TextStyle(
                            fontSize: AppSizes.textBody,
                            color: AppColors.secondLabel,
                          ),
                        ),
                        Text(
                          '${wallet.btcBalance.toStringAsFixed(8)} BTC',
                          style: const TextStyle(
                            fontSize: AppSizes.textTitle3,
                            fontWeight: FontWeight.w700,
                            color: AppColors.btcOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => AppCard(
                  child: Text('Failed to load wallet: $e'),
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),

              // Recipient address
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Recipient Address',
                        hint: 'Enter BTC address or select from contacts',
                        type: AppTextFieldType.text,
                        controller: _addressController,
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.secondLabel,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _scanQRCode(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipient address';
                          }
                          if (value.length < 26 || value.length > 62) {
                            return 'Invalid BTC address format';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),

              // Amount input
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Amount (BTC)',
                        hint: '0.00000000',
                        type: AppTextFieldType.number,
                        controller: _amountController,
                        prefixIcon: const Icon(
                          Icons.currency_bitcoin,
                          color: AppColors.btcOrange,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
                        ],
                        suffixIcon: TextButton(
                          onPressed: () => _setMaxAmount(),
                          child: const Text('MAX'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing12),

                      // USD equivalent
                      _buildUsdEquivalent(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),

              // Send button
              AppButton(
                text: 'Send BTC',
                type: AppButtonType.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                isLoading: transferState.isSending,
                onPressed: _handleSend,
              ),

              // Error message
              if (transferState.error != null) ...[
                const SizedBox(height: AppSizes.spacing16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing12,
                    vertical: AppSizes.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Expanded(
                        child: Text(
                          transferState.error!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: AppSizes.textFootnote,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Success message
              if (transferState.successMessage != null) ...[
                const SizedBox(height: AppSizes.spacing16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing12,
                    vertical: AppSizes.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Expanded(
                        child: Text(
                          transferState.successMessage!,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: AppSizes.textFootnote,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsdEquivalent() {
    final btcPriceAsync = ref.watch(btcPriceStreamProvider);

    return btcPriceAsync.when(
      data: (btcPrice) {
        final amount = double.tryParse(_amountController.text) ?? 0;
        final usdValue = amount * btcPrice.priceUsd;

        return Text(
          '≈ \$${usdValue.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: AppSizes.textCaption,
            color: AppColors.secondLabel,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner coming soon')),
    );
  }

  void _setMaxAmount() {
    final wallet = ref.read(userWalletProvider).value;
    if (wallet != null) {
      // Leave some BTC for network fees (mock - 0.00001 BTC)
      final maxAmount = (wallet.btcBalance - 0.00001).clamp(0, wallet.btcBalance);
      _amountController.text = maxAmount.toStringAsFixed(8);
    }
  }

  void _handleSend() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final address = _addressController.text.trim();

    final notifier = ref.read(transferNotifierProvider.notifier);
    notifier.sendBtc(recipientAddress: address, btcAmount: amount).then((success) {
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('BTC sent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _addressController.clear();
        _amountController.clear();
        notifier.clear();
      }
    });
  }
}
