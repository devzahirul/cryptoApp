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

/// Login page widget
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spacing48),
                // Logo/Title
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.spacing16),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: AppSizes.textTitle1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: AppSizes.textBody,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondLabel,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacing48),

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
                  hint: 'Enter your password',
                  type: AppTextFieldType.password,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacing8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                      context.showSnackBar('Forgot password not implemented yet');
                    },
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing24),

                // Sign in button
                AppButton(
                  text: AppStrings.signIn,
                  fullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(authNotifierProvider.notifier).signIn(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                    }
                  },
                ),
                const SizedBox(height: AppSizes.spacing24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.secondLabel,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        AppStrings.register,
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
