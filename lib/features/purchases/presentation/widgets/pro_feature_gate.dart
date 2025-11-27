import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/paywall_screen.dart';

/// Widget that gates Pro features behind subscription check
/// If user is not Pro, shows paywall screen instead of child
class ProFeatureGate extends ConsumerWidget {
  final Widget child;
  final String featureName;
  final bool showSnackbar;

  const ProFeatureGate({
    Key? key,
    required this.child,
    required this.featureName,
    this.showSnackbar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(purchaseNotifierProvider).isPro;

    if (isPro) {
      // User has Pro subscription, show the feature
      return child;
    } else {
      // User is free tier, redirect to paywall
      if (showSnackbar) {
        // Show snackbar and return empty widget
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upgrade to Pro to unlock $featureName'),
              action: SnackBarAction(
                label: 'Upgrade',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaywallScreen(featureName: featureName),
                    ),
                  );
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        });
        return const SizedBox.shrink();
      } else {
        // Navigate to paywall screen
        return PaywallScreen(featureName: featureName);
      }
    }
  }
}

/// Function to check if Pro feature is accessible
/// Returns true if user has Pro subscription, false otherwise
/// If false and context is provided, shows paywall
bool checkProFeature(
  WidgetRef ref, {
  BuildContext? context,
  String? featureName,
}) {
  final isPro = ref.read(purchaseNotifierProvider).isPro;

  if (!isPro && context != null) {
    // Show paywall
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(featureName: featureName),
      ),
    );
  }

  return isPro;
}

/// Show Pro upgrade snackbar
void showProUpgradeSnackbar(
  BuildContext context, {
  required String featureName,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Upgrade to Pro to unlock $featureName'),
      action: SnackBarAction(
        label: 'Upgrade',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaywallScreen(featureName: featureName),
            ),
          );
        },
      ),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
