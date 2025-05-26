import 'package:flutter/foundation.dart';
 import 'package:pack/services/failure/failure.dart';

import '../../../../../../core/data/model/merchant/merchant.dart';

class MerchantServiceEditState extends ChangeNotifier {
  MerchantServiceModel _service;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFormValid = false;
  List<String> _tempServicePhotos = [];

  MerchantServiceEditState({required MerchantServiceModel service})
      : _service = service,
        _tempServicePhotos = List.from(service.servicePhotos);

  // Getters
  MerchantServiceModel get service => _service;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _isFormValid;
  List<String> get tempServicePhotos => _tempServicePhotos;

  // Setters
  void updateService(MerchantServiceModel newService) {
    _service = newService;
    _validateForm();
    notifyListeners();
  }

  void addServicePhoto(String photoUrl) {
    _tempServicePhotos.add(photoUrl);
    _service = _service.copyWith(servicePhotos: List.from(_tempServicePhotos));
    _validateForm();
    notifyListeners();
  }

  void removeServicePhoto(String photoUrl) {
    _tempServicePhotos.remove(photoUrl);
    _service = _service.copyWith(servicePhotos: List.from(_tempServicePhotos));
    _validateForm();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _validateForm() {
    _isFormValid = _service.serviceName.trim().isNotEmpty &&
        _service.description.trim().isNotEmpty &&
        _service.cityName.trim().isNotEmpty &&
        _service.address.trim().isNotEmpty &&
        _service.planRate > 0 &&
        _service.quantity > 0;
    notifyListeners();
  }
}