
import '../../data/model/product/category_model.dart';
import 'package:pack/services/service.dart';
import 'package:dartz/dartz.dart';

abstract class CategoryRepository extends IRepository {
  CategoryRepository();

  Future<Either<NetworkFailure, List<CategoryModel>>> fetchCategories();
}
