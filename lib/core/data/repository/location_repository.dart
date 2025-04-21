import 'package:dartz/dartz.dart';
import 'package:my_ad/core/data/model/location_model.dart';
import 'package:my_ad/core/domain/repository/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Either<LocationRepositoryFailure, LocationModel>>
  getCurrentLocation() async {
    return right(LocationModel(name: 'name', id: 'id'));
  }

  @override
  String get repositoryName => 'locationRepositoryImpl';
  // This class will handle the location data
  // and provide methods to access it.
  // For example, you might want to fetch the user's current location,
  // or get a list of nearby locations.
}
