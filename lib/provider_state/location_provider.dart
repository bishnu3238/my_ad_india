import 'package:flutter/foundation.dart';

 import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  static const String _prefsKey = 'selectedCity';
  String _currentLocation = 'Kolkata'; // Default city
  LocationResponse? _locationResponse;
  bool _isLoading = false;
  String? _error;

  String get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LocationProvider() {
    _loadSavedCity();
  }

  // Load saved city from shared preferences
  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString(_prefsKey);
      if (savedCity != null && savedCity.isNotEmpty) {
        _currentLocation = savedCity;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load saved city';
    }
  }

  // Save selected city to shared preferences
  Future<void> _saveCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, city);
    } catch (e) {
      _error = 'Failed to save city preference';
    }
  }

  // Set selected city and save it
  void setCity(String city) {
    _currentLocation = city;
    _saveCity(city);
    _error = null;
    notifyListeners();
  }

  // Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check location permission status
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error =
          'Location services are disabled. Please enable them in your device settings.';
      notifyListeners();
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error =
            'Location permissions are denied. Please grant location access.';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error =
          'Location permissions are permanently denied. Please enable in app settings.';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Auto-detect user's location
  Future<LocationResponse> detectUserLocation() async {
    _isLoading = true;
    _error = null;

    notifyListeners();
    String city = 'Unknown';
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return LocationResponse.empty;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      // Get city name from coordinates
      final placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placeMarks.isNotEmpty) {
        // Extract city name from placeMarks
        city =
            placeMarks.first.locality ??
            placeMarks.first.subAdministrativeArea ??
            placeMarks.first.administrativeArea ??
            'Unknown';

        if (city != 'Unknown') {
          setCity(city);
        } else {
          _error = 'Could not determine city from your location';
        }
      } else {
        _error = 'Could not determine your location';
      }
      return LocationResponse(
        city: city,
        state: placeMarks.first.administrativeArea ?? 'Unknown',
        country: placeMarks.first.country!,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      _error = 'Error detecting location: ${e.toString()}';
      return LocationResponse.empty;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}

class LocationResponse {
  final String city, state, country;
  final double latitude, longitude;

  const LocationResponse({
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  static LocationResponse empty = LocationResponse(
    city: 'Unknown',
    state: 'Unknown',
    country: 'Unknown',
    latitude: 0.0,
    longitude: 0.0,
  );

  bool get isEmpty => this == empty;

  @override
  String toString() {
    return 'LocationResponse{city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude}';
  }
}
