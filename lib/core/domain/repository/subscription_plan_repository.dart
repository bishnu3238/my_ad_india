import '../../data/model/model.dart';
import 'package:pack/services/service.dart';
 import 'package:dartz/dartz.dart';

abstract class SubscriptionPlanRepository extends IRepository{

  Future<Either<NetworkFailure, List<SubscriptionPlanModel>>> getSubscriptionPlans();

  /// Get the current merchant's subscription
  Future<Either<NetworkFailure, MerchantSubscriptionModel>> getCurrentSubscription(String merchantId);

  /// Subscribe to a new plan
  Future<Either<NetworkFailure, MerchantSubscriptionModel>> subscribeToPlan(String planId);

}