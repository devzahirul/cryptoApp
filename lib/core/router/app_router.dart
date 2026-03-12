import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_wallet/features/auth/presentation/pages/login_page.dart';
import 'package:crypto_wallet/features/auth/presentation/pages/register_page.dart';
import 'package:crypto_wallet/features/auth/presentation/pages/profile_page.dart';
import 'package:crypto_wallet/features/wallet/presentation/pages/wallet_home_page.dart';
import 'package:crypto_wallet/features/history/presentation/pages/transaction_history_page.dart';
import 'package:crypto_wallet/features/trade/presentation/pages/buy_sell_page.dart';
import 'package:crypto_wallet/features/transfer/presentation/pages/send_page.dart';
import 'package:crypto_wallet/features/transfer/presentation/pages/receive_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Route names constant class
class RouteNames {
  RouteNames._();

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Main app routes (shell)
  static const String home = '/home';
  static const String history = '/history';
  static const String buySell = '/buy-sell';
  static const String send = '/send';
  static const String receive = '/receive';
  static const String profile = '/profile';

  // Initial route
  static const String initial = '/';
}

/// Check if user is authenticated
bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

/// App router configuration with auth guard
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.initial,
  redirect: (context, state) {
    // Listen to auth state changes
    final authState = _isAuthenticated;
    final isLoggingIn = state.uri.path == RouteNames.login ||
        state.uri.path == RouteNames.register;

    // If not authenticated and not trying to log in, redirect to login
    if (!authState && !isLoggingIn) {
      return RouteNames.login;
    }

    // If authenticated and trying to access auth pages, redirect to home
    if (authState && isLoggingIn) {
      return RouteNames.home;
    }

    // Redirect initial route to appropriate page
    if (state.uri.path == RouteNames.initial) {
      return authState ? RouteNames.home : RouteNames.login;
    }

    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),

    // Shell route for main app with bottom navigation
    ShellRoute(
      builder: (context, state, child) => WalletHomePage(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const SizedBox(), // Home is the default page in WalletHomePage
          ),
          routes: [
            GoRoute(
              path: RouteNames.history,
              name: 'history',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const TransactionHistoryPage(),
              ),
            ),
            GoRoute(
              path: RouteNames.buySell,
              name: 'buySell',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const BuySellPage(),
              ),
            ),
            GoRoute(
              path: RouteNames.send,
              name: 'send',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const SendPage(),
              ),
            ),
            GoRoute(
              path: RouteNames.receive,
              name: 'receive',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const ReceivePage(),
              ),
            ),
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const ProfilePage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
