import 'package:flutter/material.dart';
import 'package:crypto_wallet/core/constants/app_strings.dart';
import 'package:crypto_wallet/shared/widgets/error_empty_state.dart';

/// Profile page - placeholder
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: const EmptyState(
        title: 'Coming Soon',
        message: 'Profile settings will be implemented soon.',
        icon: Icons.person,
      ),
    );
  }
}
