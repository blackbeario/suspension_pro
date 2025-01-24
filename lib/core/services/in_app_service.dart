import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:suspension_pro/views/in_app_purchases/presentation/consumable_store.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static const String _kConsumableId = '30_ai_credits';
  final bool _kAutoConsume = Platform.isIOS || true;
  static const List<String> _kProductIds = <String>[_kConsumableId];
  final InAppBloc _bloc = InAppBloc();

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (isAvailable) {
      _bloc.isAvailable = true;
      await _getProducts();
      _verifyPurchase();
      // _subscription = _inAppPurchase.purchaseStream.listen((data) {
      //   _purchases.addAll(data);
      // });
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      _bloc.queryProductError = productDetailResponse.error!.message;
      return;
    }

    if (productDetailResponse.productDetails.isNotEmpty) {
      final List<String> consumables = await ConsumableStore.load(); // example loads from sharedPrefs
      _bloc.consumables = consumables;
      // _bloc.purchases = productDetailResponse.productDetails.
    } else {
      _bloc.consumables = <String>[];
    }

    _bloc.products = productDetailResponse.productDetails;
    _bloc.notFoundIds = productDetailResponse.notFoundIDs;
    _bloc.purchases = <PurchaseDetails>[];
    _bloc.purchasePending = false;
    _bloc.loading = false;
    return;
  }

  PurchaseDetails? _hasPurchased(String productID) {
    if (_bloc.purchases.isNotEmpty) return _bloc.purchases.firstWhere((purchase) => purchase.productID == productID);
    return null;
  }

  void completePurchase(PurchaseDetails purchaseDetails) async {
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  /// Always verify a purchase before delivering the product.
  void _verifyPurchase() {
    PurchaseDetails? purchaseDetails = _hasPurchased(_kConsumableId);

    if (purchaseDetails != null && purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails != null && purchaseDetails.status == PurchaseStatus.restored) {
      _bloc.addToPurchases(purchaseDetails);
      _bloc.credits = 30;
      _bloc.purchasePending = false;
    }
  }

  void buyCredits(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
  }

  void buyProAccount(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Save consumable to DB (SharedPrefs) consumables list then update UI state
  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    _bloc.consumables = consumables;
  }

  Future<void> confirmPriceChange(BuildContext contextd) async {
    // Price changes for Android are not handled by the application, but are
    // instead handled by the Play Store. See
    // https://developer.android.com/google/play/billing/price-changes for more
    // information on price changes on Android.
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  void spendCredits(PurchaseDetails purchaseDetails) {}
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
