import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Loading overlay widget
/// Shows a full-screen loading indicator
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: AppSizes.spacing16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: AppSizes.textBody,
                            fontWeight: FontWeight.w500,
                            color: AppColors.label,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple loading widget for inline loading states
class LoadingWidget extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const LoadingWidget({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Shimmer loading widget for skeleton screens
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius8),
      ),
    );
  }
}
