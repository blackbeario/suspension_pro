import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';

class ConnectivityBloc extends ChangeNotifier {
  // Private constructor to prevent direct instantiation
  ConnectivityBloc._internal();

  // Static instance variable
  static final ConnectivityBloc _instance = ConnectivityBloc._internal();
  factory ConnectivityBloc() => _instance;

  bool _isConnected = true;

  bool get isConnected => _isConnected;
  void set isConnected(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  checkConnectivity() async {
    isConnected = await ConnectivityWrapper.instance.isConnected;
  }
}
