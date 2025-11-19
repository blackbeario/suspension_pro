import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_notifier.g.dart';

/// StateNotifier for managing connectivity state
/// Replaces the ConnectivityBloc singleton pattern
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  bool build() {
    // Initialize and check connectivity
    _checkConnectivity();
    return true; // Default to connected
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    final isConnected = await ConnectivityWrapper.instance.isConnected;
    state = isConnected;
  }

  /// Update connectivity status
  void updateConnectivity(bool isConnected) {
    state = isConnected;
  }

  /// Check connectivity and update state
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }
}
