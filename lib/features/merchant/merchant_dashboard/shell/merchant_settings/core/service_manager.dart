import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceManager extends ChangeNotifier {
  bool _isServiceEnabled = true;
  bool _isAutoAcceptOrders = false;
  int _maxConcurrentOrders = 10;
  double _serviceFeePercentage = 2.5;

  bool get isServiceEnabled => _isServiceEnabled;
  bool get isAutoAcceptOrders => _isAutoAcceptOrders;
  int get maxConcurrentOrders => _maxConcurrentOrders;
  double get serviceFeePercentage => _serviceFeePercentage;

  void toggleServiceEnabled(bool value) {
    _isServiceEnabled = value;
    // Simulate API call to enable/disable service
    print('Service ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void toggleAutoAcceptOrders(bool value) {
    _isAutoAcceptOrders = value;
    // Simulate API call to toggle auto-accept
    print('Auto-accept orders ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setMaxConcurrentOrders(int max) {
    _maxConcurrentOrders = max;
    // Simulate API call to update max orders
    print('Max concurrent orders set to $max');
    notifyListeners();
  }

  void setServiceFeePercentage(double fee) {
    _serviceFeePercentage = fee;
    // Simulate API call to update service fee
    print('Service fee set to $fee%');
    notifyListeners();
  }
}

