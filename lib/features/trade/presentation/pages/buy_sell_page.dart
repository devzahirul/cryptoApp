import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/shared/widgets/app_button.dart';
import 'package:crypto_wallet/shared/widgets/app_text_field.dart';
import 'package:crypto_wallet/shared/widgets/app_card.dart';
import 'package:crypto_wallet/features/trade/presentation/providers/trade_provider.dart';
import 'package:crypto_wallet/features/market/presentation/providers/btc_price_provider.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';

/// Buy/Sell BTC page
class BuySellPage extends ConsumerStatefulWidget {
  const BuySellPage({super.key});

  @override
  ConsumerState<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends ConsumerState<BuySellPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  bool _isBuy = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _isBuy = _tabController.index == 0;
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final btcPriceAsync = ref.watch(btcPriceStreamProvider);
    final walletAsync = ref.watch(userWalletProvider);
    final tradeState = ref.watch(tradeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade BTC'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondLabel,
          tabs: const [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
          ],
        ),
      ),
      body: btcPriceAsync.when(
        data: (btcPrice) {
          final btcPriceValue = btcPrice.priceUsd;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Price ticker
                _buildPriceTicker(btcPriceValue),
                const SizedBox(height: AppSizes.spacing16),

                // Wallet balances
                walletAsync.when(
                  data: (wallet) => _buildWalletBalances(wallet),
                  loading: () => const AppCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => AppCard(
                    child: Text('Failed to load wallet: $e'),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing24),

                // Amount input
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: _isBuy ? 'USD Amount' : 'BTC Amount',
                          hint: '0.00',
                          type: AppTextFieldType.number,
                          controller: _amountController,
                          prefixIcon: Icon(
                            _isBuy ? Icons.attach_money : Icons.currency_bitcoin,
                            color: AppColors.secondLabel,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacing12),

                        // USD/BTC conversion
                        _buildConversionInfo(btcPriceValue),
                        const SizedBox(height: AppSizes.spacing16),

                        // Quick amount buttons
                        _buildQuickAmountButtons(btcPriceValue),
                        const SizedBox(height: AppSizes.spacing24),

                        // Action button
                        AppButton(
                          text: _isBuy ? 'Buy BTC' : 'Sell BTC',
                          type: _isBuy ? AppButtonType.primary : AppButtonType.danger,
                          size: AppButtonSize.large,
                          fullWidth: true,
                          isLoading: tradeState.isLoading,
                          onPressed: () => _handleTrade(btcPriceValue),
                        ),

                        // Error message
                        if (tradeState.error != null) ...[
                          const SizedBox(height: AppSizes.spacing12),
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
                                    tradeState.error!,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: AppSizes.spacing16),
              Text('Failed to load BTC price: $e'),
              const SizedBox(height: AppSizes.spacing16),
              AppButton(
                text: 'Retry',
                onPressed: () => ref.invalidate(btcPriceStreamProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTicker(double btcPrice) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.currency_bitcoin, color: AppColors.btcOrange, size: 32),
                SizedBox(width: AppSizes.spacing12),
                Text(
                  'Bitcoin',
                  style: TextStyle(
                    fontSize: AppSizes.textTitle2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${btcPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: AppSizes.textTitle2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalances(dynamic wallet) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'USD Balance',
                    style: TextStyle(
                      fontSize: AppSizes.textCaption,
                      color: AppColors.secondLabel,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    '\$${wallet.usdBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppSizes.textTitle3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.surface,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BTC Balance',
                    style: TextStyle(
                      fontSize: AppSizes.textCaption,
                      color: AppColors.secondLabel,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    '${wallet.btcBalance.toStringAsFixed(8)}',
                    style: const TextStyle(
                      fontSize: AppSizes.textTitle3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.btcOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionInfo(double btcPrice) {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isBuy ? 'You will receive' : 'You will get',
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              color: AppColors.secondLabel,
            ),
          ),
          Text(
            _isBuy
                ? '${(amount / btcPrice).toStringAsFixed(8)} BTC'
                : '\$${(amount * btcPrice).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: AppSizes.textBody,
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(double btcPrice) {
    final wallet = ref.watch(userWalletProvider).value;
    if (wallet == null) return const SizedBox.shrink();

    final amounts = _isBuy
        ? [10, 50, 100]
        : [0.001, 0.01, 0.1];

    return Wrap(
      spacing: AppSizes.spacing8,
      runSpacing: AppSizes.spacing8,
      children: amounts.map((amount) {
        return ChoiceChip(
          label: Text(
            _isBuy ? '\$${amount}' : '${amount} BTC',
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: false,
          onSelected: (selected) {
            if (selected) {
              _amountController.text = amount.toString();
            }
          },
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  void _handleTrade(double btcPrice) {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final notifier = ref.read(tradeNotifierProvider.notifier);

    if (_isBuy) {
      notifier.buyBtc(usdAmount: amount, btcPrice: btcPrice).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('BTC purchased successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _amountController.clear();
        }
      });
    } else {
      notifier.sellBtc(btcAmount: amount, btcPrice: btcPrice).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('BTC sold successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _amountController.clear();
        }
      });
    }
  }
}
