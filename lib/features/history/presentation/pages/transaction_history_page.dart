import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/shared/widgets/app_card.dart';
import 'package:crypto_wallet/shared/widgets/error_empty_state.dart';
import 'package:crypto_wallet/features/history/presentation/providers/transaction_history_provider.dart';
import 'package:crypto_wallet/features/history/domain/entities/transaction_entity.dart';
import 'package:crypto_wallet/features/market/presentation/providers/btc_price_provider.dart';
import 'package:intl/intl.dart';

/// Transaction history page
class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage> {
  TransactionType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load transactions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionHistoryNotifierProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(transactionHistoryNotifierProvider.notifier).loadTransactions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final notifier = ref.read(transactionHistoryNotifierProvider.notifier);
                final filteredTransactions = _selectedFilter != null
                    ? notifier.filterByType(_selectedFilter!)
                    : transactions;

                if (filteredTransactions.isEmpty) {
                  return EmptyState(
                    title: 'No transactions',
                    message: _selectedFilter != null
                        ? 'No transactions of this type found'
                        : 'Your transaction history will appear here',
                    icon: Icons.receipt_long_outlined,
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(AppSizes.spacing16),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSizes.spacing12),
                  itemBuilder: (context, index) {
                    return _TransactionTile(
                      transaction: filteredTransactions[index],
                      onTap: () => _showTransactionDetails(context, filteredTransactions[index]),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, s) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.danger,
                      size: 48,
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    Text(
                      'Failed to load transactions: $e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        ref.read(transactionHistoryNotifierProvider.notifier).loadTransactions();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing8,
        ),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            selected: _selectedFilter == null,
            onSelected: () => setState(() => _selectedFilter = null),
          ),
          SizedBox(width: AppSizes.spacing8),
          _FilterChip(
            label: 'Buy',
            selected: _selectedFilter == TransactionType.buy,
            onSelected: () => setState(() => _selectedFilter = TransactionType.buy),
          ),
          SizedBox(width: AppSizes.spacing8),
          _FilterChip(
            label: 'Sell',
            selected: _selectedFilter == TransactionType.sell,
            onSelected: () => setState(() => _selectedFilter = TransactionType.sell),
          ),
          SizedBox(width: AppSizes.spacing8),
          _FilterChip(
            label: 'Send',
            selected: _selectedFilter == TransactionType.send,
            onSelected: () => setState(() => _selectedFilter = TransactionType.send),
          ),
          SizedBox(width: AppSizes.spacing8),
          _FilterChip(
            label: 'Receive',
            selected: _selectedFilter == TransactionType.receive,
            onSelected: () => setState(() => _selectedFilter = TransactionType.receive),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionEntity transaction) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getColor(transaction.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radius16),
                  ),
                  child: Icon(
                    _getIcon(transaction.type),
                    color: _getColor(transaction.color),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transaction.type.displayName} BTC',
                        style: const TextStyle(
                          fontSize: AppSizes.textTitle2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        DateFormat('MMMM d, y • h:mm a').format(transaction.createdAt),
                        style: const TextStyle(
                          fontSize: AppSizes.textCaption,
                          color: AppColors.secondLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing24),
            const Divider(),
            const SizedBox(height: AppSizes.spacing16),
            _DetailRow(
              label: 'Amount',
              value: '${transaction.amountBtc?.toStringAsFixed(8) ?? '-'} BTC',
            ),
            _DetailRow(
              label: 'USD Value',
              value: transaction.amountUsd != null
                  ? '\$${transaction.amountUsd!.toStringAsFixed(2)}'
                  : '-',
            ),
            _DetailRow(
              label: 'BTC Price',
              value: transaction.btcPriceAtTime != null
                  ? '\$${transaction.btcPriceAtTime!.toStringAsFixed(2)}'
                  : '-',
            ),
            _DetailRow(
              label: 'Status',
              value: transaction.status.displayName,
              valueColor: transaction.status == TransactionStatus.completed
                  ? AppColors.success
                  : transaction.status == TransactionStatus.failed
                      ? AppColors.danger
                      : AppColors.warning,
            ),
            if (transaction.fromAddress != null) ...[
              const SizedBox(height: AppSizes.spacing8),
              _DetailRow(
                label: 'From',
                value: transaction.fromAddress!,
                isAddress: true,
              ),
            ],
            if (transaction.toAddress != null) ...[
              const SizedBox(height: AppSizes.spacing8),
              _DetailRow(
                label: 'To',
                value: transaction.toAddress!,
                isAddress: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.arrow_downward;
      case TransactionType.sell:
        return Icons.arrow_upward;
      case TransactionType.send:
        return Icons.send;
      case TransactionType.receive:
        return Icons.download;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return AppColors.success;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.secondLabel,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: AppSizes.textCaption,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;

  const _TransactionTile({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCrypto = transaction.type == TransactionType.send ||
        transaction.type == TransactionType.receive;

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getColor(transaction.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
          child: Icon(
            _getIcon(transaction.type),
            color: _getColor(transaction.color),
            size: 24,
          ),
        ),
        title: Text(
          transaction.type.displayName,
          style: const TextStyle(
            fontSize: AppSizes.textBody,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.spacing4),
            Text(
              DateFormat('MMM d, y • h:mm a').format(transaction.createdAt),
              style: const TextStyle(
                fontSize: AppSizes.textCaption,
                color: AppColors.secondLabel,
              ),
            ),
            if (transaction.status == TransactionStatus.pending) ...[
              const SizedBox(height: AppSizes.spacing4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == TransactionType.send ? '-' : ''}${transaction.amountBtc?.toStringAsFixed(8) ?? '0'} BTC',
              style: TextStyle(
                fontSize: AppSizes.textBody,
                fontWeight: FontWeight.w600,
                color: _getColor(transaction.color),
              ),
            ),
            if (transaction.amountUsd != null)
              Text(
                '\$${transaction.amountUsd!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: AppSizes.textCaption,
                  color: AppColors.secondLabel,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.arrow_downward;
      case TransactionType.sell:
        return Icons.arrow_upward;
      case TransactionType.send:
        return Icons.send;
      case TransactionType.receive:
        return Icons.download;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return AppColors.success;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isAddress;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              color: AppColors.secondLabel,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isAddress ? AppSizes.textFootnote : AppSizes.textBody,
                fontWeight: isAddress ? FontWeight.normal : FontWeight.w600,
                color: valueColor ?? AppColors.label,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
