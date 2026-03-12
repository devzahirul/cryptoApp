import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/core/constants/app_strings.dart';
import 'package:crypto_wallet/core/extensions/build_context_extensions.dart';
import 'package:crypto_wallet/core/extensions/string_extensions.dart';
import 'package:crypto_wallet/shared/widgets/app_button.dart';
import 'package:crypto_wallet/shared/widgets/app_text_field.dart';
import 'package:crypto_wallet/features/auth/presentation/providers/auth_provider.dart';

/// Register page widget
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes and navigate
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated == false) {
        context.go('/home');
      }
      if (next.error != null && next.error != previous?.error) {
        context.showSnackBar(next.error!, isError: true);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spacing16),

                // Title
                Text(
                  'Create Account',
                  style: const TextStyle(
                    fontSize: AppSizes.textTitle2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Sign up to get started with ${AppStrings.appName}',
                  style: TextStyle(
                    fontSize: AppSizes.textBody,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondLabel,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing32),

                // Full name field
                AppTextField(
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacing16),

                // Email field
                AppTextField(
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  type: AppTextFieldType.email,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.isValidEmail) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacing16),

                // Password field
                AppTextField(
                  label: AppStrings.password,
                  hint: 'Create a password',
                  type: AppTextFieldType.password,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacing16),

                // Confirm password field
                AppTextField(
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  type: AppTextFieldType.password,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacing32),

                // Sign up button
                AppButton(
                  text: AppStrings.signUp,
                  fullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(authNotifierProvider.notifier).signUp(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            fullName: _fullNameController.text.trim(),
                          );
                    }
                  },
                ),
                const SizedBox(height: AppSizes.spacing24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.hasAccount,
                      style: TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.secondLabel,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
