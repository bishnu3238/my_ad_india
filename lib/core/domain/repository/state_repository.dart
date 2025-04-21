import 'package:dartz/dartz.dart';

import '../../data/model/model.dart';
import 'package:pack/services/service.dart';

abstract class StateRepository {

  // Fetch cities from the [Network]
  Future<Either<NetworkFailure, List<StateModel>>> fetchStates();


}
