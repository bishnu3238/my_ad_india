import 'package:dartz/dartz.dart';

 import '../../data/model/city_model.dart';
import 'package:pack/services/service.dart';

abstract class CitiesRepository {

  // Fetch cities from the [Network]
  Future<Either<NetworkFailure, List<CityModel>>> fetchCities();

  // Get popular cities [Assets]
  Future<Either<NetworkFailure, List<CityModel>>> getPopularCities();

  // Filter cities based on search query
  Future<Either<NetworkFailure, List<CityModel>>> filterCities(String query);


}
