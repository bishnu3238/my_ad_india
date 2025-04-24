import 'package:flutter/cupertino.dart';
import 'package:pack/services/base_services/advance_data_store.dart';
import 'package:pack/services/base_services/base_service.dart';
import '../../data/model/product/category_model.dart';
 import 'package:pack/services/search_service/search_utility.dart'; // Assuming a custom Failure type from dartz

class CategoryStore extends CollectionStore<CategoryModel> implements SearchDataStore {
  List<CategoryModel> get allCategories => items;





  CategoryModel getById(String id)=> items.firstWhere((element) => element.id == id);


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

    final filteredCategories =
        items.where((category) => category.matchesQuery(query)).toList();

    // Apply pagination if requested
    if (skip != null || take != null) {
      final start = skip ?? 0;
      final end = take != null ? start + take : filteredCategories.length;

      return filteredCategories.skip(start).take(end - start).toList();
    }

    return filteredCategories;
  }


}
