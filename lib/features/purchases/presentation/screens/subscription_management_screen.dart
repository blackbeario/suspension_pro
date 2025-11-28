import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';

/// Subscription management screen for Pro users
/// Shows active subscription details and management options
class SubscriptionManagementScreen extends ConsumerWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final subscriptionType = purchaseState.customerInfo?.activeSubscriptions[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('RideMetrx Pro'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pro status information
              if (user.subscriptionExpiryDate != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your RideMetrx $subscriptionType subscription \nauto-renews ${_formatDate(user.subscriptionExpiryDate!)}',
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),
              // Pro features list
              const Text(
                'Your Pro Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(
                icon: Icons.cloud_sync,
                title: 'Cloud Sync',
                description: 'Sync bikes and settings across devices',
                isActive: true,
              ),
              _buildFeatureItem(
                icon: Icons.analytics_outlined,
                title: 'Verifiable Feedback Data',
                description: 'Measure trail feedback with accelerometer + GPS',
                isActive: true,
              ),
              _buildFeatureItem(
                icon: Icons.compare_arrows,
                title: 'A/B Testing',
                description: 'Compare suspension settings objectively',
                isActive: true,
              ),
              _buildFeatureItem(
                icon: Icons.map_outlined,
                title: 'Strava Integration',
                description: 'Export data and track maintenance hours',
                isActive: true,
              ),
              _buildFeatureItem(
                icon: Icons.photo_library,
                title: 'Cloud Photo Storage',
                description: 'Backup bike photos across devices',
                isActive: true,
              ),

              const SizedBox(height: 24),

              // Management options
              const Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Refresh subscription status button
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(purchaseNotifierProvider.notifier).refreshCustomerInfo();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription status refreshed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              // Restore purchases button
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await ref.read(purchaseNotifierProvider.notifier).restorePurchases();

                  if (!context.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Purchases restored successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No additional purchases found'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore Purchases'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              // Manage subscription in App Store
              OutlinedButton.icon(
                onPressed: () {
                  // iOS App Store subscription management
                  loadURL('https://apps.apple.com/account/subscriptions');
                },
                icon: const Icon(Icons.settings),
                label: const Text('Manage in App Store'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              // Support section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you have any questions about your subscription or need to cancel, you can manage it directly in the App Store.',
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.green : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
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
