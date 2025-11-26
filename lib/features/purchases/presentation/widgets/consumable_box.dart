import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';

class PreviousConsumablePurchases extends ConsumerWidget {
  const PreviousConsumablePurchases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final inAppService = ref.read(inAppPurchaseServiceProvider);

    if (purchaseState.loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching consumables...'),
        ),
      );
    }

    if (!purchaseState.isAvailable || purchaseState.notFoundIds.contains('30_ai_credits')) {
      return const Center(child: ListTile(title: Text('No previous purchases')));
    }

    const ListTile consumableHeader = ListTile(title: Text('Previous Purchases'));
    final List<Widget> tokens = purchaseState.consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => inAppService.consume(id),
        ),
      );
    }).toList();

    return Card(
      child: Column(
        children: [
          consumableHeader,
          const Divider(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: purchaseState.consumables.isNotEmpty
                ? tokens
                : const [Text('No purchased consumables')],
          ),
        ],
      ),
    );
  }
}
