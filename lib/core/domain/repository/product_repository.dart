import 'package:dartz/dartz.dart';
import 'package:pack/services/failure/failure.dart';

import '../../data/model/model.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductModel>>> fetchEadProducts();
  Future<Either<Failure, List<ProductModel>>> fetchProductsByCategory(String i);
}
