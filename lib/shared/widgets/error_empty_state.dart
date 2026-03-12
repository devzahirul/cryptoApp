import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Error state widget for displaying error messages
class ErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: AppSizes.iconXl,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSizes.spacing24),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: AppSizes.textTitle2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                ),
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: AppSizes.spacing8),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppSizes.textBody,
                fontWeight: FontWeight.w400,
                color: AppColors.secondLabel,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.spacing24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                    vertical: AppSizes.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget for displaying empty screens
class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? icon;
  final Widget? illustration;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.onAction,
    this.actionLabel,
    this.icon,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: AppSizes.spacing24),
            ] else if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconXl,
                  color: AppColors.secondLabel,
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),
            ],
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: AppSizes.textTitle2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                ),
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: AppSizes.spacing8),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppSizes.textBody,
                fontWeight: FontWeight.w400,
                color: AppColors.secondLabel,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppSizes.spacing24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                    vertical: AppSizes.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
