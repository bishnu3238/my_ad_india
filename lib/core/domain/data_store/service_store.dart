import 'dart:developer' as dev;

 import 'package:pack/services/base_services/base_service.dart';
import 'package:pack/services/search_service/search_utility.dart';

import '../../data/model/product/service_model.dart';

class ServiceStore extends CollectionStore<ServiceModel>
    implements SearchDataStore {
  ServiceStore() : super(initialItems: []);

  @override
  Future<List<Searchable>> getAll() => Future.value(items);

  @override
  Future<List<Searchable>> searchItems(
    String query, {
    int? skip,
    int? take,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final filteredService =
        items.where((service) => service.matchesQuery(query)).toList();

    // Apply pagination if requested
    if (skip != null || take != null) {
      final start = skip ?? 0;
      final end = take != null ? start + take : filteredService.length;

      return filteredService.skip(start).take(end - start).toList();
    }

    return filteredService;
  }
}
