import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'; // Import stays the same
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  StreamSubscription? _subscription;

  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      bool isDeviceConnected = result != ConnectivityResult.none;
      if (!isDeviceConnected) {
        _updateConnectionStatus(false);
        return;
      }

      // Correct usage: InternetConnection() singleton
      bool hasInternet = await InternetConnection().hasInternetAccess;
      _updateConnectionStatus(hasInternet);
    });

    // Initial check
    checkConnection();
  }

  Future<void> checkConnection() async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    _updateConnectionStatus(hasInternet);
  }

  void _updateConnectionStatus(bool status) {
    if (_hasInternet != status) {
      _hasInternet = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}