import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';

import '../../features/chat_feature/models/inquiry.dart';
import '../data/api/api_config.dart';
import '../data/model/model.dart';
import '../domain/data_store/data_store.dart';
import '../domain/repository/repository.dart';
import 'package:pack/services/service.dart';

import '../injector/dependency_injection.dart';

class ProductService {
  final ProductStore _store;
  final ProductRepository _repository;

  const ProductService(this._store, this._repository);

  Future<void> fetchProducts() async {
    _store.setStatus(DataStoreStatus.loading);

    final result = await _repository.fetchEadProducts();
    result.fold(
      (failure) => _store.setError(OperationFailure(message: failure.message)),
      (products) => _store.setItems(products),
    );
  }

  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    /// TODO: this is for local or fast approach;
    // return _store.items.where((e) => '${e.categoryId}' == categoryId).toList();
    /// OR
    /// TODO: call a api
    return await _repository
        .fetchProductsByCategory(categoryId)
        .then((value) => value.getRight());
  }

  Future<List<ProductModel>> fetchNearbyProviders(
    FetchNearByProductsOfUserPayload payload,
  ) async {
    return await _repository
        .fetchNearByProductsOfUser(payload)
        .then((value) => value.getRight());
  }

  Future submitInquiry({required SubmitInquiryPayload payload}) async {
    dev.log('Form is not valid');

    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.saveInquries,
      body: payload.toJson(),
      method: RequestMethod.post,
    );

    await DependencyInjector.get<ApiCallService>().request(
      config: config,
      responseConverter: (data) {
        dev.log("Inquiry submitted successfully: $data");
      },
    );
  }

  Future<List<Inquiry>> getInquiry(String merchantId) async {
    dev.log('Form is not valid');

    final config = RequestConfig(
      baseUrl: ApiConfig.baseUrl,
      endpoint: ApiConfig.getMerchantInquiry,
      queryParameters: {'merchantId': merchantId},
      method: RequestMethod.get,
    );

    return await DependencyInjector.get<ApiCallService>()
        .request(
          config: config,
          responseConverter: (data) {
            dev.log("Inquiry Getting successfully: $data");
            List<Inquiry> _inquiries = [];
            if (data is List) {
              _inquiries =
                  data
                      .where((e) => e is Map<String, dynamic>)
                      .map(
                        (e) => Inquiry.fromJson(
                          _fixInquiryJson(e as Map<String, dynamic>),
                        ),
                      )
                      .toList();
            } else {
              _inquiries = [];
            }
            return _inquiries;
          },
        )
        .then(
          (value) => value.fold((failure) {
            return [];
          }, (result) => result.data!),
        );
  }
}

Map<String, dynamic> _fixInquiryJson(Map<String, dynamic> json) {
  // Some APIs use snake_case, some camelCase, some missing fields
  return {
    'id': json['id'],
    'conversation_id': json['conversation_id'],
    'customer_id': json['customer_id'],
    'merchant_id': json['merchant_id'],
    'subject': json['subject'] ?? '',
    'message': json['message'] ?? '',
    'attachment_url': json['attachment_url'],
    'status': json['status'] ?? '',
    'notes': json['notes'],
    'created_at': json['created_at'],
    'updated_at': json['updated_at'],
    'customer_name': json['customer_name'],
    'customer_image': json['customer_image'],
    'merchant_name': json['merchant_name'],
    'merchant_image': json['merchant_image'],
  };
}
