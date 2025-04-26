// connectivity_service.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api_services/src/log_service.dart';

class ConnectivityService {
   final Connectivity _connectivity = Connectivity();
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  // Throttle mechanism
  DateTime _lastCheck = DateTime.now();
  static const Duration _throttleDuration = Duration(seconds: 5);

  ConnectivityService() {
    _initConnectivityListener();
  }

  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus == ConnectivityStatus.online;
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;


  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // Throttle to prevent too frequent checks
      if (DateTime.now().difference(_lastCheck) < _throttleDuration) {
        return;
      }
      _lastCheck = DateTime.now();

      // Check real internet connectivity
      final hasInternet = await hasActiveInternet();
      _currentStatus = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
    });

    // Initial check
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final hasInternet = await hasActiveInternet();
    _currentStatus = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        return ConnectivityStatus.online;
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
      default:
        return ConnectivityStatus.offline;
    }
  }

  Future<bool> isConnectionHas() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
    } catch (e, stack) {
      dev.log('Error checking connectivity $e, $stack');
      return false;
    }
  }

  Future<bool> hasActiveInternet() async {
    try {
      if (!await isConnectionHas()) return false;

      // Try multiple reliable domains
      for (final domain in ['google.com', 'apple.com', 'microsoft.com']) {
        try {
          final response = await InternetAddress.lookup(domain)
              .timeout(const Duration(seconds: 3));
          if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          // Try next domain
          continue;
        }
      }
      return false;
    } catch (e) {
      dev.log('No active internet connection');
      return false;
    }
  }
}

enum ConnectivityStatus { online, offline }