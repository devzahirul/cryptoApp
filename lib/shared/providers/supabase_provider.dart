import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase instance provider
/// Provides the singleton Supabase instance throughout the app
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase URL from environment
String get supabaseUrl {
  return dotenv.env['SUPABASE_URL'] ??
    (kDebugMode
      ? throw Exception('SUPABASE_URL not found in .env.local')
      : 'https://placeholder.supabase.co');
}

/// Supabase Anon Key from environment
String get supabaseAnonKey {
  return dotenv.env['SUPABASE_ANON_KEY'] ??
    (kDebugMode
      ? throw Exception('SUPABASE_ANON_KEY not found in .env.local')
      : 'placeholder-key');
}

/// Initialize Supabase
/// Call this in main.dart before runApp
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: kDebugMode,
  );
}

/// Auth state stream provider
/// Watch this to react to authentication changes
final authStateStreamProvider = StreamProvider<AuthState?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

/// Current user provider
/// Returns the current authenticated user or null
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser;
});

/// Auth session provider
/// Returns the current session or null
final authSessionProvider = Provider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentSession;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
