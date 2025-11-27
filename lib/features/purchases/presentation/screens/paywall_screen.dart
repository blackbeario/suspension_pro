import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

/// Paywall screen showing Pro features and pricing
/// Displayed when free users try to access Pro features
class PaywallScreen extends ConsumerWidget {
  final String? featureName;

  const PaywallScreen({Key? key, this.featureName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section
                Icon(
                  Icons.rocket_launch,
                  size: 80,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                Text(
                  'RideMetrx Pro',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
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
                  isPro: true,
                ),
                _buildFeatureItem(
                  icon: Icons.analytics_outlined,
                  title: 'Metrx Roughness Detection',
                  description: 'Measure trail roughness with accelerometer + GPS data',
                  isPro: true,
                ),
                _buildFeatureItem(
                  icon: Icons.compare_arrows,
                  title: 'A/B Testing',
                  description: 'Objectively compare suspension settings between runs',
                  isPro: true,
                ),
                _buildFeatureItem(
                  icon: Icons.map_outlined,
                  title: 'Strava Integration',
                  description: 'Auto-track ride hours and link trail names',
                  isPro: true,
                ),
                _buildFeatureItem(
                  icon: Icons.share_location,
                  title: 'Community Contributions',
                  description: 'Share your heatmap data with other riders',
                  isPro: true,
                ),
                _buildFeatureItem(
                  icon: Icons.photo_library,
                  title: 'Cloud Photo Storage',
                  description: 'Backup bike photos across devices',
                  isPro: true,
                ),

                const SizedBox(height: 32),

                // Pricing cards
                _buildPricingCard(
                  context,
                  title: 'Monthly',
                  price: '\$2.99',
                  period: '/month',
                  productId: kProMonthlyId,
                  isRecommended: false,
                  purchaseState: purchaseState,
                  ref: ref,
                ),
                const SizedBox(height: 16),
                _buildPricingCard(
                  context,
                  title: 'Annual',
                  price: '\$29.99',
                  period: '/year',
                  productId: kProAnnualId,
                  isRecommended: true,
                  savingsText: 'Save 17%',
                  purchaseState: purchaseState,
                  ref: ref,
                ),

                const SizedBox(height: 24),

                // Restore purchases button
                TextButton(
                  onPressed: () async {
                    await ref.read(purchaseNotifierProvider.notifier).restorePurchases();
                  },
                  child: const Text('Restore Purchases'),
                ),

                const SizedBox(height: 8),

                // Maybe later button
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isPro,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isPro ? Colors.teal : Colors.grey,
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

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String productId,
    required bool isRecommended,
    String? savingsText,
    required dynamic purchaseState,
    required WidgetRef ref,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? Colors.teal : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isRecommended ? Colors.teal.withValues(alpha: 0.05) : Colors.white,
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (savingsText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    savingsText,
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: purchaseState.purchasePending
                  ? null
                  : () async {
                      // TODO: Implement purchase flow with InAppPurchase
                      // For now, just show a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase flow not yet implemented'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? Colors.teal : Colors.grey.shade700,
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
                  : Text(
                      'Subscribe',
                      style: const TextStyle(
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
}
