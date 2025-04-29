import 'package:flutter/foundation.dart';

import '../../../core/data/model/model.dart';

// State class to represent different states of the service list
abstract class ServiceListState {
  const ServiceListState();
}

class ServiceListInitial extends ServiceListState {
  const ServiceListInitial();
}

class ServiceListLoading extends ServiceListState {
  const ServiceListLoading();
}

class ServiceListLoaded extends ServiceListState {
  final List<ServiceModel> services;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final SortOption sortOption;

  const ServiceListLoaded({
    required this.services,
    required this.categories,
    required this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = SortOption.popularity,
  });

  ServiceListLoaded copyWith({
    List<ServiceModel>? services,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return ServiceListLoaded(
      services: services ?? this.services,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class ServiceListError extends ServiceListState {
  final String message;

  const ServiceListError(this.message);
}

enum SortOption { popularity, priceHighToLow, priceLowToHigh, newest }
