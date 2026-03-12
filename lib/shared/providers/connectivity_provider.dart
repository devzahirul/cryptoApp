import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state provider
/// Monitors network connectivity and provides current state
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Connectivity state
enum ConnectivityState {
  /// Device has active internet connection
  connected,

  /// Device has no internet connection
  disconnected,

  /// Connection status is unknown (initial state)
  unknown,
}

/// Connectivity state notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(ConnectivityState.unknown) {
    _init();
  }

  Future<void> _init() async {
    // Check initial connection state
    await _checkConnectivity();

    // Listen for connectivity changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateState(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateState(results);
    } catch (e) {
      state = ConnectivityState.disconnected;
    }
  }

  void _updateState(List<ConnectivityResult> results) {
    // Check if any result indicates a connection
    final hasConnection = results.any((result) {
      return result != ConnectivityResult.none;
    });

    state = hasConnection ? ConnectivityState.connected : ConnectivityState.disconnected;
  }

  /// Check if currently connected
  bool get isConnected => state == ConnectivityState.connected;

  /// Check if currently disconnected
  bool get isDisconnected => state == ConnectivityState.disconnected;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Connectivity check provider (one-time check)
final connectivityCheckProvider = FutureProvider<bool>((ref) async {
  try {
    final results = await Connectivity().checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  } catch (e) {
    return false;
  }
});
