import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Reusable card widget with Apple-inspired design
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final bool enableShadow;
  final double? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.enableShadow = true,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSizes.spacing16),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.cardDark : AppColors.card),
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.cardBorderRadius),
        border: border,
        boxShadow: enableShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : AppColors.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.cardBorderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSizes.spacing16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Balance card widget for displaying wallet balance
class BalanceCard extends StatelessWidget {
  final String title;
  final String balance;
  final String? subtitle;
  final Color? gradientStart;
  final Color? gradientEnd;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    this.subtitle,
    this.gradientStart,
    this.gradientEnd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientStart ?? AppColors.primary,
              gradientEnd ?? AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.textFootnote,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              balance,
              style: const TextStyle(
                fontSize: AppSizes.textTitle2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.spacing4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: AppSizes.textSubhead,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
