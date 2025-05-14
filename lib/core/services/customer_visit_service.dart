import 'package:my_ad/core/data/model/payload/POST/customer_visit_payload.dart';
import 'package:my_ad/core/domain/repository/customer_visit_repository.dart';

import '../data/model/customer_visit_model.dart';
import '../data/model/response/customer_visit_response.dart';

class CustomerVisitService {
  final CustomerVisitRepository _repository;

  CustomerVisitService(this._repository);

  Future<void> submitVisit(SubmitCustomerVisitPayload payload) async {
    await _repository.submitVisit(payload);
  }

  Future<CustomerVisitResponse<List<CustomerVisit>>> getMerchantVisits(
    int merchantId,
  ) async {
    return await _repository.getVisits(merchantId: merchantId);
  }
}
