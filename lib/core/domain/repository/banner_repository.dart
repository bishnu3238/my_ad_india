 import 'package:dartz/dartz.dart';
import '../../data/model/banner_model.dart';
 import 'package:pack/services/service.dart';

abstract class BannerRepository extends IRepository {
  BannerRepository();

  Future<Either<NetworkFailure, List<BannerModel>>> getBanners();
}