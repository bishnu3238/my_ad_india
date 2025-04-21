import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/failure/failure.dart';
import 'package:dartz/dartz.dart';
import '../../data/repository/user_repository/user_repository_requests.dart';

abstract class UserRepository {

  Future<Either<Failure, UserModel>> updateProfile({
    required UpdateProfileRequest request,
  });

  Future<Either<Failure, UserModel>> updateProfilePicture(String imagePath);
}
