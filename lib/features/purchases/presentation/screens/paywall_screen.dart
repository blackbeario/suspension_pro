import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ridemetrx/core/themes/styles.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/features/purchases/domain/paywall_display_manager.dart';

/// Paywall screen showing Pro features and pricing
/// Displayed when free users try to access Pro features
class PaywallScreen extends ConsumerStatefulWidget {
  final String? featureName;
  final VoidCallback? onDismiss;
  final bool? showAppBar;

  const PaywallScreen({Key? key, this.featureName, this.onDismiss, this.showAppBar}) : super(key: key);

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch offerings when screen loads
    Future.microtask(() {
      ref.read(purchaseNotifierProvider.notifier).fetchOfferings();
    });

    // Record that paywall was shown
    PaywallDisplayManager.recordPaywallShown();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final offerings = purchaseState.offerings;

    return Scaffold(
      body: SafeArea(
        child: purchaseState.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero section
                      Image.asset('assets/ride_metrx_logo_bw.png', height: 100),
                      const SizedBox(height: 16),
                      Text(
                        'RideMetrx Pro',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Turn your phone into a \$300 ShockWiz alternative',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Feature list
                      _buildFeatureItem(
                        icon: Icons.cloud_sync,
                        title: 'Cloud Sync',
                        description: 'Sync your bikes and settings across all devices',
                      ),
                      _buildFeatureItem(
                        icon: Icons.analytics_outlined,
                        title: 'Verifyable Feedback Data',
                        description: 'Measure trail feedback with accelerometer + GPS data',
                      ),
                      _buildFeatureItem(
                        icon: Icons.compare_arrows,
                        title: 'A/B Testing',
                        description: 'Objectively compare suspension settings between runs',
                      ),
                      _buildFeatureItem(
                        icon: Icons.map_outlined,
                        title: 'Strava Integration',
                        description: 'Export data, auto-track maintenance hours and link trail names',
                      ),
                      // _buildFeatureItem(
                      //   icon: Icons.share_location,
                      //   title: 'Community Contributions',
                      //   description: 'Share your Metrx heatmap data with other riders',
                      // ),
                      _buildFeatureItem(
                        icon: Icons.photo_library,
                        title: 'Cloud Photo Storage',
                        description: 'Backup bike photos across devices',
                      ),

                      const SizedBox(height: 32),

                      // Pricing cards from RevenueCat
                      if (offerings != null && offerings.current != null)
                        ..._buildOfferingPackages(offerings.current!)
                      else
                        const Center(
                          child: Text('No subscription options available'),
                        ),

                      const SizedBox(height: 24),

                      // Restore purchases button
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(purchaseNotifierProvider.notifier)
                              .restorePurchases();

                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Purchases restored successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No active subscriptions found'),
                              ),
                            );
                          }
                        },
                        child: const Text('Restore Purchases'),
                      ),

                      const SizedBox(height: 8),

                      // Maybe later button
                      TextButton(
                        onPressed: () {
                          widget.onDismiss?.call();
                          context.pop();
                        },
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),

                      // Error message
                      if (purchaseState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            purchaseState.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildOfferingPackages(Offering offering) {
    final packages = offering.availablePackages;
    final widgets = <Widget>[];

    // Find monthly and annual packages
    final monthlyPackage = packages.firstWhere(
      (p) => p.packageType == PackageType.monthly,
      orElse: () => packages.first,
    );

    final annualPackage = packages.firstWhere(
      (p) => p.packageType == PackageType.annual,
      orElse: () => packages.last,
    );

    // Monthly package
    widgets.add(_buildPackageCard(
      context: context,
      package: monthlyPackage,
      isRecommended: false,
    ));

    widgets.add(const SizedBox(height: 16));

    // Annual package
    widgets.add(_buildPackageCard(
      context: context,
      package: annualPackage,
      isRecommended: true,
    ));

    return widgets;
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required Package package,
    required bool isRecommended,
  }) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final product = package.storeProduct;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? Colors.blue : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isRecommended ? Colors.blue.withValues(alpha: 0.05) : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.title.replaceAll('(RideMetrx)', '').trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: RideMetrxTheme().themedata.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.priceString,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: purchaseState.purchasePending
                  ? null
                  : () async {
                      final success = await ref
                          .read(purchaseNotifierProvider.notifier)
                          .purchaseProduct(package);

                      if (!mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Welcome to RideMetrx Pro!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? Colors.blue : Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: purchaseState.purchasePending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Subscribe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
