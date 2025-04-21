import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import '../api/api_config.dart';
import 'package:pack/services/service.dart';

import '../../domain/repository/service_repository.dart';
import '../model/product/service_model.dart';

class ServiceRepositoryImpl extends ServiceRepository {
  final ApiCallService _apiCallService;
  ServiceRepositoryImpl(this._apiCallService);

  @override
  Future<Either<NetworkFailure, List<ServiceModel>>> fetchServices() async {
    try {
      return await _apiCallService
          .request<List<ServiceModel>?>(
            config: RequestConfig(
              baseUrl: ApiConfig.baseUrl,
              endpoint: ApiConfig.services,
              method: RequestMethod.get,
            ),
            responseConverter: (data) => _convertServices(data),
          )
          .then(
            (value) => value.fold(
              (failure) => left(failure),
              (result) => right(result.data!),
            ),
          );
    } catch (e) {
      dev.log('Error fetching services: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  // List<ServiceModel> _convertServices(dynamic data) {
  //   try {
  //     dev.log('Converting services data: ${data.runtimeType}');
  //
  //     // Ensure data is a List
  //     if (data is! List) {
  //       dev.log('Data is not a List: $data');
  //       return [];
  //     }

  List<ServiceModel>? _convertServices(data) {
    try {
      LogService().info('Converting services data');
      dev.log('Converting services data $data');
    } catch (e, s) {
      dev.log('$s');
    }
    if (data is List) {
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    }
    return null;
  }

  @override
  String get repositoryName => 'ServiceRepositoryImpl';
}

// List<ServiceModel> _convertServices(dynamic data) {
//   try {
//     dev.log('Converting services data: ${data.runtimeType}');
//
//     // Ensure data is a List
//     if (data is! List) {
//       dev.log('Data is not a List: $data');
//       return [];
//     }
//
//     // Convert List<dynamic> to List<ServiceModel>
//     final List<ServiceModel> services = [];
//     for (var item in data) {
//       if (item is Map<String, dynamic>) {
//         try {
//           services.add(ServiceModel.fromJson(item));
//         } catch (e, s) {
//           dev.log(
//             'Error parsing individual service: $e',
//             error: e,
//             stackTrace: s,
//           );
//           continue; // Skip malformed items
//         }
//       } else {
//         dev.log('Item is not a Map: $item');
//         continue; // Skip non-map items
//       }
//     }
//
//     dev.log('Successfully converted ${services.length} services');
//     return services;
//   } catch (e, s) {
//     dev.log('Error converting services data: $e', error: e, stackTrace: s);
//     return [];
//   }
// }
