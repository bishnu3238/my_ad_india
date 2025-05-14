import '../../data/model/customer_visit_model.dart';
import '../../data/model/payload/POST/customer_visit_payload.dart';
import '../../data/model/response/customer_visit_response.dart';

abstract class CustomerVisitRepository {
  /// Submit a new customer visit
  Future<CustomerVisitResponse<int>> submitVisit(
    SubmitCustomerVisitPayload payload,
  );

  /// Get a list of customer visits for a merchant (with optional filters)
  Future<CustomerVisitResponse<List<CustomerVisit>>> getVisits({
    required int merchantId,
    int? limit,
    int? offset,
    String? status,
    int? customerId,
  });

  /// Get a single customer visit by ID (optionally filter by merchant)
  Future<CustomerVisitResponse<CustomerVisit>> getVisitById({
    required int id,
    int? merchantId,
  });

  /// Update the status of a customer visit
  Future<CustomerVisitResponse<void>> updateVisitStatus(
    UpdateCustomerVisitPayload payload,
  );
}
