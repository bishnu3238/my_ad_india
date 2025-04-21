import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

import '../../../../core/domain/data_store/data_store.dart';
import '../../../../core/injector/dependency_injection.dart';
import '../../../ead_products/core/ead_product_navigator.dart';
import 'search_suggestion.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecentSearchStorage>(
      future: RecentSearchStorage.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }

        final recentSearchStorage = snapshot.data!;

        return ChangeNotifierProvider(
          create:
              (context) => SearchProvider(
                repository: SearchRepositoryImpl(
                  stores: [
                    DependencyInjector.get<CategoryStore>(),
                    DependencyInjector.get<SubCategoryStore>(),
                    DependencyInjector.get<ServiceStore>(),
                  ],

                  maxSuggestionsPerType: 5,
                ),

                recentSearchStorage: recentSearchStorage,
              ),
          child: Builder(
            builder: (context) {
              return SearchPage(
                recommendedSuggestions: SearchSuggestionView(
                  suggestions: [
                    ...DependencyInjector.get<CategoryStore>().items.take(5),
                    ...DependencyInjector.get<SubCategoryStore>().items.take(5),
                    ...DependencyInjector.get<ServiceStore>().items.take(5),
                  ],
                  onSuggestionTap:
                      (searchable) => onResultTap(searchable, context),
                  isLoading: context.watch<SearchProvider>().isLoading,
                  query: '',
                ),
                onResultTap: (searchable) => onResultTap(searchable, context),
              );
            },
          ),
        );
      },
    );
  }

  onResultTap(Searchable searchable, BuildContext context) {
    dev.log('SEARCH RESULT TAB: $searchable');
    switch (searchable.resultType) {
      case SearchResultType.category:
        context.push(
          '${EadProductRoute.eadServices}/${searchable.id}/${ProductSearchBy.category.name}',
        );
      case SearchResultType.subCategory:
        context.push(
          '${EadProductRoute.eadServices}/${searchable.id}/${ProductSearchBy.subCategory.name}',
        );
      case SearchResultType.service:
        context.push(
          '${EadProductRoute.eadServices}/${searchable.id}/${ProductSearchBy.service.name}',
        );
      case SearchResultType.merchant:
        context.push(
          '${EadProductRoute.eadServices}/${searchable.id}/${ProductSearchBy.merchant.name}',
        );
      case SearchResultType.eadProduct:
        context.push(
          '${EadProductRoute.eadServices}/${searchable.id}/${ProductSearchBy.product.name}',
        );
    }
  }
}
