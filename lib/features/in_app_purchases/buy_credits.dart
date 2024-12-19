// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:suspension_pro/features/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/connection_check_tile.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/consumable_box.dart';
import 'package:suspension_pro/features/in_app_purchases/presentation/product_list.dart';
import 'package:suspension_pro/services/in_app_service.dart';

class BuyCredits extends StatefulWidget {
  const BuyCredits();

  @override
  State<BuyCredits> createState() => _BuyCreditsState();
}

class _BuyCreditsState extends State<BuyCredits> {
  final InAppBloc _bloc = InAppBloc();
  final InAppPurchaseService _service = InAppPurchaseService();

  @override
  void initState() {
    _service.initStoreInfo();
    super.initState();
  }

// @override
//   void dispose() {
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//           _inAppPurchase
//               .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       iosPlatformAddition.setDelegate(null);
//     }
//     _subscription.cancel();
//     super.dispose();
//   }

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
            // _buildRestoreButton(),
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
      appBar: AppBar(
        title: const Text('Buy AI Credits'),
      ),
      body: Stack(
        children: stack,
      ),
    );
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
    //       CupertinoDialogAction(child: Text('Buy More'), onPressed: () {} // TODO: Add buy credits screen,
    //           ),
    //     ],
    //   );
    // }
    //   return ElevatedButton(onPressed: () => _service.buyCredits(), child: Text('Buy Credits'));
    // });
  }
}
