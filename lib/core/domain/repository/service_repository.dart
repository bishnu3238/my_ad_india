import 'package:flutter/foundation.dart';
import 'package:pack/services/base_services/base_service.dart';
import 'package:pack/services/failure/failure.dart';

import '../../data/model/product/service_model.dart';

import 'package:dartz/dartz.dart';

abstract class ServiceRepository  extends IRepository{

Future<Either<NetworkFailure, List<ServiceModel>>> fetchServices();
Future<Either<NetworkFailure, List<ServiceModel>>> fetchServicesByCategory(String categoryId);


}


// Service repository for data operations
// class ServiceRepofsitory {
//   // Singleton pattern
//
//   // Parse a list of services from json
//   List<ServiceModel> parseServices(List<dynamic> json) {
//     return json
//         .map((serviceJson) {
//       try {
//         if (serviceJson is Map<String, dynamic>) {
//           return ServiceModel.fromJson(serviceJson);
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print('Error parsing service: $e');
//         }
//       }
//       return null;
//     })
//         .where((service) => service != null)
//         .cast<ServiceModel>()
//         .toList();
//   }
//
//   // Group services by category
//   Map<String, List<ServiceModel>> groupByCategory(List<ServiceModel> services) {
//     final Map<String, List<ServiceModel>> grouped = {};
//
//     for (final service in services) {
//       final categoryName = service.categoryName ?? 'Uncategorized';
//       if (!grouped.containsKey(categoryName)) {
//         grouped[categoryName] = [];
//       }
//       grouped[categoryName]!.add(service);
//     }
//
//     return grouped;
//   }
//
//   // Group services by subcategory
//   Map<String, List<ServiceModel>> groupBySubcategory(List<ServiceModel> services) {
//     final Map<String, List<ServiceModel>> grouped = {};
//
//     for (final service in services) {
//       final subcategoryName = service.subcategoryName ?? 'Uncategorized';
//       if (!grouped.containsKey(subcategoryName)) {
//         grouped[subcategoryName] = [];
//       }
//       grouped[subcategoryName]!.add(service);
//     }
//
//     return grouped;
//   }
//
//   // Search services by keyword
//   List<ServiceModel> searchServices(List<ServiceModel> services, String query) {
//     if (query.isEmpty) return services;
//
//     final lowercaseQuery = query.toLowerCase();
//     return services.where((service) {
//       return service.serviceName.toLowerCase().contains(lowercaseQuery) ||
//           service.description.toLowerCase().contains(lowercaseQuery);
//     }).toList();
//   }
// }