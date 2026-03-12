import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';

/// Text field type enum
enum AppTextFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
}

/// Reusable app text field with validation
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final AppTextFieldType type;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int? maxLengthEnforcement;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.type = AppTextFieldType.text,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.readOnly = false,
    this.maxLengthEnforcement,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isObscure = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.type == AppTextFieldType.password;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: AppSizes.textSubhead,
              fontWeight: FontWeight.w500,
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _isObscure,
          maxLines: widget.type == AppTextFieldType.multiline
              ? (widget.maxLines ?? 4)
              : 1,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(
            fontSize: AppSizes.textBody,
            fontWeight: FontWeight.w400,
            color: AppColors.label,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _getSuffixIcon(),
            filled: true,
            fillColor: _hasFocus
                ? AppColors.surface
                : AppColors.surface.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing16,
              vertical: AppSizes.spacing12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(
              color: AppColors.secondLabel,
              fontSize: AppSizes.textBody,
            ),
            errorStyle: const TextStyle(
              color: AppColors.danger,
              fontSize: AppSizes.textFootnote,
            ),
            counterStyle: const TextStyle(
              color: AppColors.secondLabel,
              fontSize: AppSizes.textFootnote,
            ),
          ),
          focusNode: FocusNode()
            ..addListener(() {
              setState(() {
                _hasFocus = FocusNode().hasFocus;
              });
            }),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.password:
      case AppTextFieldType.text:
      case AppTextFieldType.multiline:
        return TextInputType.text;
    }
  }

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.type == AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.secondLabel,
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      );
    }

    return null;
  }
}
