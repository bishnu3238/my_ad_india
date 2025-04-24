import 'package:flutter/cupertino.dart';
import 'package:pack/services/base_services/base_service.dart';
import '../../data/model/product/sub_category_model.dart'; // Replace with your model
import 'package:pack/services/failure/failure.dart';
import 'package:pack/services/search_service/search_utility.dart';

class SubCategoryStore extends CollectionStore<SubCategoryModel>
    with SortableMixin<SubCategoryModel>
    implements SearchDataStore {




  SubCategoryModel getById(String id)=> items.firstWhere((element) => element.id == id);


  @override
  Future<List<Searchable>> getAll() async => Future.value(items);

  @override
  Future<List<Searchable>> searchItems(
    String query, {
    int? skip,
    int? take,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final filteredSubCategories =
        items.where((subCategory) => subCategory.matchesQuery(query)).toList();

    // Apply pagination if requested
    if (skip != null || take != null) {
      final start = skip ?? 0;
      final end = take != null ? start + take : filteredSubCategories.length;

      return filteredSubCategories.skip(start).take(end - start).toList();
    }

    return filteredSubCategories;
  }
}
