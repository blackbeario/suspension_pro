import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/core/services/in_app_service.dart';

class InAppProductList extends StatelessWidget {
  const InAppProductList();

  @override
  Widget build(BuildContext context) {
    final InAppBloc _bloc = InAppBloc();
    final InAppPurchaseService _service = InAppPurchaseService();
    return ListenableBuilder(
        listenable: _bloc,
        builder: (context, widget) {
          if (_bloc.loading) {
            return const Card(child: ListTile(title: Text('Fetching products...')));
          }
          if (!_bloc.isAvailable) {
            return const Card(child: ListTile(title: Text('Store not available')));
          }
          final List<ListTile> productList = <ListTile>[];
          if (_bloc.notFoundIds.isNotEmpty) {
            productList.add(ListTile(
                title: Text('[${_bloc.notFoundIds.join(", ")}] not found',
                    style: TextStyle(color: ThemeData.light().colorScheme.error)),
                subtitle: const Text(
                    'This app needs special configuration to run. Please see example/README.md for instructions.')));
          }

          final Map<String, PurchaseDetails> purchases = Map<String, PurchaseDetails>.fromEntries(
            _bloc.purchases.map((PurchaseDetails purchase) {
              if (purchase.pendingCompletePurchase) {
                _service.completePurchase(purchase);
              }
              return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
            }),
          );

          productList.addAll(_bloc.products.map(
            (ProductDetails productDetails) {
              final PurchaseDetails? previousPurchase = purchases[productDetails.id];
              return ListTile(
                title: Text(productDetails.title),
                subtitle: Text(productDetails.description),
                trailing: previousPurchase != null && Platform.isIOS
                    ? IconButton(onPressed: () => _service.confirmPriceChange(context), icon: const Icon(Icons.upgrade))
                    : TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (productDetails.id == '30_ai_credits') {
                            _service.buyCredits(productDetails);
                          } else if (productDetails.id == 'pro_account') {
                            _service.buyProAccount(productDetails);
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
        });
  }
}
