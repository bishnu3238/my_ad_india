import 'dart:developer' as dev;

import 'package:pack/services/service.dart';

import '../../domain/repository/customer_visit_repository.dart';
import '../api/api_config.dart';
import '../model/customer_visit_model.dart';
import '../model/payload/POST/customer_visit_payload.dart';
import '../model/response/customer_visit_response.dart';

class CustomerVisitRepositoryImpl implements CustomerVisitRepository {
  final ApiCallService apiService;
  final String baseUrl;

  CustomerVisitRepositoryImpl({
    required this.apiService,
    required this.baseUrl,
  });

  @override
  Future<CustomerVisitResponse<int>> submitVisit(
    SubmitCustomerVisitPayload payload,
  ) async {
    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: ApiConfig.submitCustomerVisit,
      method: RequestMethod.post,
      body: payload.toJson(),
      responseFormat: ResponseFormat.json,
      requiresAuth: false,
    );
    final result = await apiService.request<Map<String, dynamic>>(
      config: config,
      responseConverter: (data) {
        dev.log("Response data: $data");
        return data as Map<String, dynamic>;
      },
    );
    return result.fold(
      (failure) => CustomerVisitResponse<int>(
        status: 'error',
        message: failure.message,
        data: null,
      ),
      (response) => CustomerVisitResponse.generic(response.data ?? {}),
    );
  }

   @override
  Future<CustomerVisitResponse<List<CustomerVisit>>> getVisits({
    required int merchantId,
    int? limit,
    int? offset,
    String? status,
    int? customerId,
  }) async {
    final params = <String, dynamic>{
      'merchant_id': merchantId.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
      if (status != null) 'status': status,
      if (customerId != null) 'customer_id': customerId.toString(),
    };
    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: ApiConfig.getCustomerVisits,
      method: RequestMethod.get,
      queryParameters: params,
      responseFormat: ResponseFormat.json,
      requiresAuth: false,
    );
    final result = await apiService.request<Map<String, dynamic>>(
      config: config,
      responseConverter: (data) {
        dev.log("Response data Get Customer Visits: $data");
        return data as Map<String, dynamic>;
      },
    );
    return result.fold(
          (failure) => CustomerVisitResponse<List<CustomerVisit>>(
        status: 'error',
        message: failure.message,
        data: null,
      ),
          (response) => CustomerVisitResponse.multipleVisits(
        response.data ?? {},
            (list) => CustomerVisit.fromJsonList(list),
      ),
    );
  }
  @override
  Future<CustomerVisitResponse<CustomerVisit>> getVisitById({
    required int id,
    int? merchantId,
  }) async {
    final params = <String, dynamic>{
      'id': id,
      if (merchantId != null) 'merchant_id': merchantId,
    };
    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: ApiConfig.getCustomerVisitById,
      method: RequestMethod.get,
      queryParameters: params,
      responseFormat: ResponseFormat.json,
      requiresAuth: false,
    );
    final result = await apiService.request<Map<String, dynamic>>(
      config: config,
      responseConverter: (data) => data as Map<String, dynamic>,
    );
    return result.fold(
      (failure) => CustomerVisitResponse<CustomerVisit>(
        status: 'error',
        message: failure.message,
        data: null,
      ),
      (response) => CustomerVisitResponse.singleVisit(
        response.data ?? {},
        (json) => CustomerVisit.fromJson(json),
      ),
    );
  }

  @override
  Future<CustomerVisitResponse<void>> updateVisitStatus(
    UpdateCustomerVisitPayload payload,
  ) async {
    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: ApiConfig.updateCustomerVisit,
      method: RequestMethod.post,
      body: payload.toJson(),
      responseFormat: ResponseFormat.json,
      requiresAuth: false,
    );
    final result = await apiService.request<Map<String, dynamic>>(
      config: config,
      responseConverter: (data) => data as Map<String, dynamic>,
    );
    return result.fold(
      (failure) => CustomerVisitResponse<void>(
        status: 'error',
        message: failure.message,
        data: null,
      ),
      (response) => CustomerVisitResponse.generic(response.data ?? {}),
    );
  }
}
