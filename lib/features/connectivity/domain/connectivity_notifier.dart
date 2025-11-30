import 'dart:async';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_notifier.g.dart';

/// StateNotifier for managing connectivity state with periodic polling
/// Replaces the ConnectivityBloc singleton pattern
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  Timer? _pollingTimer;

  @override
  bool build() {
    // Check immediately
    _checkConnectivity();

    // Poll connectivity every 3 seconds for real-time updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkConnectivity();
    });

    // Cleanup timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return true; // Default to connected (will update immediately)
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final isConnected = await ConnectivityWrapper.instance.isConnected;
      if (state != isConnected) {
        print('ConnectivityNotifier: Connectivity changed to: ${isConnected ? "ONLINE" : "OFFLINE"}');
        state = isConnected;
      }
    } catch (e) {
      print('ConnectivityNotifier: Error checking connectivity: $e');
    }
  }

  /// Update connectivity status (for manual overrides if needed)
  void updateConnectivity(bool isConnected) {
    state = isConnected;
  }

  /// Check connectivity and update state
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }
}
