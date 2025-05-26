// lib/features/favorites/core/favorites_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/data/model/model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<ServiceModel> favoriteServices;
  final List<ServiceModel> filteredServices;
  final String searchQuery;
  final FavoritesSortOption sortOption;
  final bool isGridView;

  const FavoritesLoaded({
    required this.favoriteServices,
    required this.filteredServices,
    this.searchQuery = '',
    this.sortOption = FavoritesSortOption.dateAdded,
    this.isGridView = true,
  });

  FavoritesLoaded copyWith({
    List<ServiceModel>? favoriteServices,
    List<ServiceModel>? filteredServices,
    String? searchQuery,
    FavoritesSortOption? sortOption,
    bool? isGridView,
  }) {
    return FavoritesLoaded(
      favoriteServices: favoriteServices ?? this.favoriteServices,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      isGridView: isGridView ?? this.isGridView,
    );
  }

  @override
  List<Object?> get props => [
    favoriteServices,
    filteredServices,
    searchQuery,
    sortOption,
    isGridView,
  ];
}

class FavoritesEmpty extends FavoritesState {
  const FavoritesEmpty();
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

enum FavoritesSortOption {
  dateAdded,
  alphabetical,
  priceHighToLow,
  priceLowToHigh,
}

extension FavoritesSortOptionExtension on FavoritesSortOption {
  String get displayName {
    switch (this) {
      case FavoritesSortOption.dateAdded:
        return 'Recently Added';
      case FavoritesSortOption.alphabetical:
        return 'A to Z';
      case FavoritesSortOption.priceHighToLow:
        return 'Price: High to Low';
      case FavoritesSortOption.priceLowToHigh:
        return 'Price: Low to High';
    }
  }

  IconData get icon {
    switch (this) {
      case FavoritesSortOption.dateAdded:
        return Icons.access_time;
      case FavoritesSortOption.alphabetical:
        return Icons.sort_by_alpha;
      case FavoritesSortOption.priceHighToLow:
        return Icons.trending_down;
      case FavoritesSortOption.priceLowToHigh:
        return Icons.trending_up;
    }
  }
}