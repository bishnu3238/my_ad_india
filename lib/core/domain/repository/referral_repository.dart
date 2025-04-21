import 'package:dartz/dartz.dart';
import 'package:pack/services/failure/failure.dart';

import '../../data/model/request/request.dart';
import '../../data/model/response/referral_response.dart';

abstract class ReferralRepository {
  Future<void> createReferral(String referralCode);
  Future<void> redeemReferral(String referralCode);
  Future<void> getReferralDetails(String referralCode);
  Future<Either<Failure, ReferralResponse>> submitReferral(PostReferralRequest request);
}