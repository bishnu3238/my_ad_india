import '../../data/model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:pack/services/failure/failure.dart';

abstract class SubCategoryRepository {
  Future<Either<NetworkFailure, List<SubCategoryModel>>> getSubCategories();
}
