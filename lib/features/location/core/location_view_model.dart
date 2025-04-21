import 'package:flutter/foundation.dart';
import '../../../core/domain/data_store/cities_store.dart';

import '../../../core/data/model/city_model.dart';
import '../../../core/data/model/location_model.dart';

class LocationScreenProvider extends ChangeNotifier {
  final CitiesStore _citiesStore;

  List<CityModel> get _allCities => _citiesStore.items;

  List<LocationModel> _filteredLocations = [];

  LocationScreenProvider(this._citiesStore) {
    _filteredLocations = List.from(
      _allCities.map((e) => LocationModel.toLocation(e)),
    );
  }

  List<LocationModel> get locations => _filteredLocations;

  List<CityModel> get popularCities => _citiesStore.getDefaultPopularCities;

  List<CityModel> get getOtherCities => _citiesStore.getOtherCities();

  search(String query) {
    if (query.isEmpty) {
      return _allCities;
    } else {
      return _allCities
          .where((l) => l.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
