import 'dart:io';

import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/purchases/domain/purchase_notifier.dart';
import 'package:suspension_pro/core/providers/service_providers.dart';
import 'package:suspension_pro/features/purchases/presentation/widgets/connection_check_tile.dart';
import 'package:suspension_pro/features/purchases/presentation/widgets/consumable_box.dart';
import 'package:suspension_pro/features/purchases/presentation/widgets/product_list.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class BuyCredits extends ConsumerStatefulWidget {
  const BuyCredits({Key? key}) : super(key: key);

  @override
  ConsumerState<BuyCredits> createState() => _BuyCreditsState();
}

class _BuyCreditsState extends ConsumerState<BuyCredits> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    super.initState();
    // Initialize store info through service provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inAppPurchaseServiceProvider).initStoreInfo();
    });
  }

@override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    // _bloc.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final List<Widget> stack = <Widget>[];

    if (purchaseState.queryProductError == null) {
      stack.add(
        ListView(
          children: const <Widget>[
            ConnectionCheckTile(),
            InAppProductList(),
            PreviousConsumablePurchases(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(purchaseState.queryProductError!),
      ));
    }

    if (purchaseState.purchasePending) {
      stack.add(
        const Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Buy AI Credits'),
        actions: const [
          SizedBox(
            width: 60,
            child: ConnectivityWidgetWrapper(
              alignment: Alignment.centerLeft,
              offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
            ),
          ),
        ],
      ),
      body: ConnectivityWidgetWrapper(
        alignment: Alignment.center,
        stacked: false,
        offlineWidget: const Center(child: Text('You cannot buy credits while offline')),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(children: stack),
        ),
      ),
    );
  }
}
