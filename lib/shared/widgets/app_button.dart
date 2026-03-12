import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Button type enum
enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

/// Button size enum
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Reusable app button with multiple styles
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);

    if (isLoading) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: _getButtonHeight(),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? _getDefaultTextColor(),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: AppSizes.spacing8),
                  Text(text),
                ],
              )
            : Text(text),
      ),
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppSizes.buttonHeightMedium;
      case AppButtonSize.large:
        return AppSizes.buttonHeightLarge;
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    Color? effectiveBackgroundColor = backgroundColor;
    Color? effectiveTextColor = textColor;

    switch (type) {
      case AppButtonType.primary:
        effectiveBackgroundColor ??= AppColors.primary;
        effectiveTextColor ??= Colors.white;
        break;
      case AppButtonType.secondary:
        effectiveBackgroundColor ??= AppColors.surface;
        effectiveTextColor ??= AppColors.label;
        break;
      case AppButtonType.outline:
        effectiveBackgroundColor ??= Colors.transparent;
        effectiveTextColor ??= AppColors.primary;
        break;
      case AppButtonType.text:
        effectiveBackgroundColor ??= Colors.transparent;
        effectiveTextColor ??= AppColors.primary;
        break;
      case AppButtonType.danger:
        effectiveBackgroundColor ??= AppColors.danger;
        effectiveTextColor ??= Colors.white;
        break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveTextColor,
      elevation: type == AppButtonType.outline || type == AppButtonType.text ? 0 : null,
      padding: EdgeInsets.symmetric(
        horizontal: size == AppButtonSize.small
            ? AppSizes.spacing12
            : AppSizes.spacing24,
        vertical: AppSizes.spacing12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        side: type == AppButtonType.outline
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      textStyle: TextStyle(
        fontSize: size == AppButtonSize.small
            ? AppSizes.textSubhead
            : AppSizes.textBody,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getDefaultTextColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
        return AppColors.label;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
    }
  }
}
