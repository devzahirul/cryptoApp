import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/core/constants/app_strings.dart';
import 'package:crypto_wallet/shared/widgets/loading_overlay.dart';
import 'package:crypto_wallet/shared/widgets/error_empty_state.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:crypto_wallet/features/market/presentation/providers/btc_price_provider.dart';
import 'package:crypto_wallet/features/market/presentation/widgets/price_ticker_widget.dart';
import 'package:crypto_wallet/features/wallet/presentation/widgets/balance_card_widget.dart';

/// Wallet home page - main screen after login
class WalletHomePage extends ConsumerStatefulWidget {
  final Widget? child;

  const WalletHomePage({
    super.key,
    this.child,
  });

  @override
  ConsumerState<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends ConsumerState<WalletHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(userWalletProvider);
    final btcPrice = ref.watch(btcPriceProvider);
    final btcPriceLoading = ref.watch(btcPriceLoadingProvider);

    // Check current route - only show child for nested routes (not /home)
    final location = GoRouterState.of(context).uri.path;
    final isNestedRoute = location != '/home' &&
                          location != '/home/' &&
                          location.startsWith('/home/');

    // If on a nested route with a valid child, display it
    if (isNestedRoute && widget.child != null) {
      return widget.child!;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: walletAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(userWalletProvider),
        ),
        data: (wallet) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userWalletProvider);
            ref.invalidate(btcPriceStreamProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price ticker
                PriceTickerWidget(
                  price: btcPrice,
                  isLoading: btcPriceLoading,
                ),
                const SizedBox(height: AppSizes.spacing20),

                // Balance card
                BalanceCardWidget(
                  wallet: wallet,
                  btcPrice: btcPrice?.priceUsd ?? 0,
                ),
                const SizedBox(height: AppSizes.spacing20),

                // Quick actions
                QuickActionsRow(
                  onBuy: () => context.pushNamed('buySell'),
                  onSell: () => context.pushNamed('buySell'),
                  onSend: () => context.pushNamed('send'),
                  onReceive: () => context.pushNamed('receive'),
                ),
                const SizedBox(height: AppSizes.spacing24),

                // BTC Address
                Card(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                  child: BtcAddressWidget(address: wallet.btcAddress),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text(
        AppStrings.appName,
        style: TextStyle(
          fontSize: AppSizes.textTitle2,
          fontWeight: FontWeight.w700,
          color: AppColors.label,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.secondLabel,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications not implemented yet')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // TODO: Handle navigation
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondLabel,
    );
  }
}
