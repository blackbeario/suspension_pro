import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/connectivity/domain/connectivity_notifier.dart';

/// A widget that wraps its child and shows different content based on connectivity status
/// Replaces the old ConnectivityWidgetWrapper that used Provider<ConnectivityStatus>
class ConnectivityWidgetWrapper extends ConsumerWidget {
  const ConnectivityWidgetWrapper({
    Key? key,
    required this.child,
    this.offlineWidget,
    this.stacked = true,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  /// The widget to display when online
  final Widget child;

  /// The widget to display when offline (if null, only child is shown)
  final Widget? offlineWidget;

  /// Whether to stack the offline widget on top of the child
  final bool stacked;

  /// Alignment for stacked offline widget
  final Alignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityNotifierProvider);

    if (isConnected) {
      // Online - show child
      return child;
    } else {
      // Offline
      if (offlineWidget == null) {
        // No offline widget provided, just show child
        return child;
      }

      if (stacked) {
        // Stack offline widget on top of child
        return Stack(
          alignment: alignment,
          children: [
            child,
            offlineWidget!,
          ],
        );
      } else {
        // Show only offline widget
        return offlineWidget!;
      }
    }
  }
}
