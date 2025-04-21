import 'package:dartz/dartz.dart';

import 'package:my_ad/core/data/model/user/user_model.dart';
import 'package:pack/services/api_services/api_services.dart';

import 'package:pack/services/failure/failure.dart';

import '../../../domain/repository/repository.dart';
import 'user_repository_requests.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiCallService apiCallService;
  UserRepositoryImpl(this. apiCallService);

  @override
  Future<Either<Failure, UserModel>> updateProfile({required UpdateProfileRequest request}) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> updateProfilePicture(String imagePath) {
    // TODO: implement updateProfilePicture
    throw UnimplementedError();
  }

}
