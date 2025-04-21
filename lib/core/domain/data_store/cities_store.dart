import 'package:flutter/material.dart';
import 'package:pack/services/base_services/base_service.dart';
import '../../data/model/city_model.dart';

class CitiesStore extends CollectionStore<CityModel> {
  List<CityModel> getPopularCities() {
    return items.where((city) => city.isPopular).toList();
  }

  List<CityModel> get getDefaultCities => defaultCities;
  List<CityModel> get getDefaultPopularCities =>
      defaultCities.where((e) => e.isPopular).toList();

  CityModel getCityById(String id) => items.firstWhere((e) => e.name == id);

  List<CityModel> getOtherCities() {
    return items.where((city) => city.isPopular).toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
  }

  List<CityModel> filterCities(String query) {
    if (query.isEmpty) {
      return [];
    }

    return defaultCities
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

// List of cities with popular ones marked and given icons
final List<CityModel> defaultCities = [
  // Popular cities
  CityModel(id: '1', name: 'Mumbai', icon: Icons.business, isPopular: true),
  CityModel(
    id: '1',
    name: 'Delhi-NCR',
    icon: Icons.account_balance,
    isPopular: true,
  ),
  CityModel(id: '1', name: 'Bengaluru', icon: Icons.park, isPopular: true),
  CityModel(id: '1', name: 'Hyderabad', icon: Icons.mosque, isPopular: true),
  CityModel(id: '1', name: 'Ahmedabad', icon: Icons.apartment, isPopular: true),
  CityModel(
    id: '1',
    name: 'Chandigarh',
    icon: Icons.location_city,
    isPopular: true,
  ),
  CityModel(
    id: '1',
    name: 'Chennai',
    icon: Icons.beach_access,
    isPopular: true,
  ),
  CityModel(id: '1', name: 'Pune', icon: Icons.castle, isPopular: true),
  CityModel(id: '1', name: 'Kolkata', icon: Icons.pool, isPopular: true),
  CityModel(id: '1', name: 'Kochi', icon: Icons.sailing, isPopular: true),

  // Other cities in alphabetical order
  CityModel(id: '1', name: 'Aalo', isPopular: false),
  CityModel(id: '1', name: 'Abohar', isPopular: false),
  CityModel(id: '1', name: 'Abu Road', isPopular: false),
  CityModel(id: '1', name: 'Achhnera', isPopular: false),
  CityModel(id: '1', name: 'Adhiyamankottai', isPopular: false),
  CityModel(id: '1', name: 'Adilabad', isPopular: false),
  CityModel(id: '1', name: 'Adityapur', isPopular: false),
  CityModel(id: '1', name: 'Adoni', isPopular: false),
  CityModel(id: '1', name: 'Agartala', isPopular: false),
  CityModel(id: '1', name: 'Agra', isPopular: false),
  CityModel(id: '1', name: 'Ahmedabad', isPopular: false),
  CityModel(id: '1', name: 'Ahmednagar', isPopular: false),
  CityModel(id: '1', name: 'Aizawl', isPopular: false),
  CityModel(id: '1', name: 'Ajmer', isPopular: false),
  CityModel(id: '1', name: 'Akola', isPopular: false),
  CityModel(id: '1', name: 'Alappuzha', isPopular: false),
  CityModel(id: '1', name: 'Aligarh', isPopular: false),
  CityModel(id: '1', name: 'Alipurduar', isPopular: false),
  CityModel(id: '1', name: 'Allahabad', isPopular: false),
  CityModel(id: '1', name: 'Almora', isPopular: false),
  CityModel(id: '1', name: 'Alwar', isPopular: false),
  CityModel(id: '1', name: 'Ambala', isPopular: false),
  CityModel(id: '1', name: 'Amravati', isPopular: false),
  CityModel(id: '1', name: 'Amreli', isPopular: false),
  CityModel(id: '1', name: 'Amritsar', isPopular: false),
  CityModel(id: '1', name: 'Anand', isPopular: false),
  CityModel(id: '1', name: 'Anantapur', isPopular: false),
  CityModel(id: '1', name: 'Angul', isPopular: false),
  CityModel(id: '1', name: 'Ankleshwar', isPopular: false),
  CityModel(id: '1', name: 'Arrah', isPopular: false),
  CityModel(id: '1', name: 'Asansol', isPopular: false),
  CityModel(id: '1', name: 'Aurangabad', isPopular: false),
  CityModel(id: '1', name: 'Azamgarh', isPopular: false),
  // Add more cities as needed
];
