// Location Model
import 'city_model.dart';

class LocationModel {
  final String id;
  final String name;
  final String? state;
  final String? svgPath;
  final double? lat, lng;

  LocationModel({
    required this.name,
    required this.id,
      this.state,
     this.svgPath,
    this.lat,
    this.lng,

  });

  static  LocationModel toLocation (CityModel cityModel){
    return LocationModel(
      id: cityModel.id,
      name: cityModel.name,
      state: cityModel.state,
      svgPath: '',
    );
  }
}