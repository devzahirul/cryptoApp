import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_wallet/features/auth/domain/usecases/sign_in.dart';
import 'package:crypto_wallet/features/auth/domain/usecases/sign_up.dart';
import 'package:crypto_wallet/features/auth/domain/usecases/sign_out.dart';
import 'package:crypto_wallet/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:crypto_wallet/features/auth/data/datasources/auth_datasource.dart';
import 'package:crypto_wallet/shared/providers/supabase_provider.dart';

/// Supabase client provider (already in shared, but referenced here)
/// final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Auth datasource provider
final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuthDatasource(supabase);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

/// Sign in use case provider
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

/// Sign up use case provider
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

/// Sign out use case provider
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthNotifier({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        super(const AuthState());

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signInUseCase.execute(email: email, password: password);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        error: null,
      ),
    );
  }

  /// Sign up with email, password, and full name
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signUpUseCase.execute(
      email: email,
      password: password,
      fullName: fullName,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        error: null,
      ),
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signOutUseCase.execute();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = const AuthState(
        isAuthenticated: false,
        user: null,
        error: null,
        isLoading: false,
      ),
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final dynamic user;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    dynamic user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInUseCase: ref.watch(signInUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  );
});

/// Current user provider
final authUserProvider = Provider<dynamic>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

/// Auth error provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.error;
});
