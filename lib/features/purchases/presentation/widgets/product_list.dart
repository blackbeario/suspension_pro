import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:suspension_pro/features/purchases/domain/purchase_notifier.dart';
import 'package:suspension_pro/core/providers/service_providers.dart';

class InAppProductList extends ConsumerWidget {
  const InAppProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final inAppService = ref.read(inAppPurchaseServiceProvider);
    if (purchaseState.loading) {
      return const Card(child: ListTile(title: Text('Fetching products...')));
    }
    if (!purchaseState.isAvailable) {
      return const Card(child: ListTile(title: Text('Store not available')));
    }

    final List<ListTile> productList = <ListTile>[];
    if (purchaseState.notFoundIds.isNotEmpty) {
      productList.add(ListTile(
        title: Text(
          '[${purchaseState.notFoundIds.join(", ")}] not found',
          style: TextStyle(color: ThemeData.light().colorScheme.error),
        ),
        subtitle: const Text(
          'This app needs special configuration to run. Please see example/README.md for instructions.',
        ),
      ));
    }

    final Map<String, PurchaseDetails> purchases = Map<String, PurchaseDetails>.fromEntries(
      purchaseState.purchases.map((PurchaseDetails purchase) {
        if (purchase.pendingCompletePurchase) {
          inAppService.completePurchase(purchase);
        }
        return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
      }),
    );

    productList.addAll(purchaseState.products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
          title: Text(productDetails.title),
          subtitle: Text(productDetails.description),
          trailing: previousPurchase != null && Platform.isIOS
              ? IconButton(
                  onPressed: () => inAppService.confirmPriceChange(context),
                  icon: const Icon(Icons.upgrade),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (productDetails.id == '30_ai_credits') {
                      inAppService.buyCredits(productDetails);
                    } else if (productDetails.id == 'pro_account') {
                      inAppService.buyProAccount(productDetails);
                    }
                  },
                  child: Text(productDetails.price),
                ),
        );
      },
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(children: productList),
    );
  }
}
