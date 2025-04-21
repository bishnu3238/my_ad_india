import 'package:dartz/dartz.dart';
import 'package:my_ad/core/data/model/location_model.dart';
import 'package:pack/services/service.dart';

import '../../data/model/city_model.dart';

abstract class LocationRepository implements IRepository{
  Future<Either<LocationRepositoryFailure, LocationModel>> getCurrentLocation();

}



class LocationRepositoryFailure extends Failure{
  const LocationRepositoryFailure({required super.message});

}