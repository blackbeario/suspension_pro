// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppBloc extends ChangeNotifier {
  // Private constructor to prevent direct instantiation
  InAppBloc._internal();

  // Static instance variable
  static final InAppBloc _instance = InAppBloc._internal();
  factory InAppBloc() => _instance;

  // late StreamSubscription<List<PurchaseDetails>> subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  int _credits = 0;

  List<ProductDetails> get products => _products;
  void set products(List<ProductDetails> products) {
    _products = products;
    notifyListeners();
  }

  List<PurchaseDetails> get purchases => _purchases;
  void set purchases(List<PurchaseDetails> purchases) => _purchases = purchases;
  addToPurchases(PurchaseDetails purchaseDetails) {
    _purchases.add(purchaseDetails);
    notifyListeners();
  }

  bool get loading => _loading;
  void set loading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  bool get isAvailable => _isAvailable;
  void set isAvailable(bool isAvailable) => _isAvailable = isAvailable;

  List<String> get notFoundIds => _notFoundIds;
  void set notFoundIds(List<String> notFoundIds) => _notFoundIds = notFoundIds;

  List<String> get consumables => _consumables;
  void set consumables(List<String> consumables) {
    _consumables = consumables;
    notifyListeners();
  }

  String? get queryProductError => _queryProductError ?? null;
  void set queryProductError(String? queryProductError) => _queryProductError = queryProductError;

  int get credits => _credits;
  void set credits(int credits) {
    _credits = credits;
    notifyListeners();
  }

  bool get purchasePending => _purchasePending;
  void set purchasePending(bool purchasePending) => _purchasePending = purchasePending;
}
