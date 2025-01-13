// import 'dart:io';
import 'dart:io';

import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/features/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/connection_check_tile.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/consumable_box.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/product_list.dart';
import 'package:suspension_pro/services/in_app_service.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class BuyCredits extends StatefulWidget {
  const BuyCredits();

  @override
  State<BuyCredits> createState() => _BuyCreditsState();
}

class _BuyCreditsState extends State<BuyCredits> {
  final InAppBloc _bloc = InAppBloc();
  final InAppPurchaseService _service = InAppPurchaseService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    _service.initStoreInfo();
    super.initState();
  }

@override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _bloc.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = <Widget>[];
    if (_bloc.queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            ConnectionCheckTile(),
            InAppProductList(),
            PreviousConsumablePurchases(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_bloc.queryProductError!),
      ));
    }
    if (_bloc.purchasePending) {
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
        // padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
        title: Text('Buy AI Credits'),
        actions: [SizedBox(
            width: 60,
            child: ConnectivityWidgetWrapper(
              alignment: Alignment.centerLeft,
              offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
            ),
          ),],
      ),
        body: ConnectivityWidgetWrapper(
          alignment: Alignment.center,
          stacked: false,
          offlineWidget: Center(child: Text('You cannot buy credits while offline')),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(children: stack),
          ),
        )
        // return ListenableBuilder(
        //     listenable: _bloc,
        //     builder: (context, widget) {
        // if (_bloc.credits < 5) {
        //   return CupertinoAlertDialog(
        //     title: Text('Warning: Low Credits'),
        //     content: Text(
        //         'You have less than 5 credits remaining. \n Please purchase additional credits to continue generating AI suggestions.'),
        //     actions: [
        //       CupertinoDialogAction(
        //         child: Text('Not Now'),
        //         onPressed: () {
        //           Navigator.pop(context, 'Discard');
        //         },
        //       ),
        //       CupertinoDialogAction(child: Text('Buy More'), onPressed: () {}
        //           ),
        //     ],
        //   );
        // }
        //   return ElevatedButton(onPressed: () => _service.buyCredits(), child: Text('Buy Credits'));
        // });
        );
  }
}
