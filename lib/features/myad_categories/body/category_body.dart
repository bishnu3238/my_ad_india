import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/all_category_view_modal.dart';
import 'category_card.dart';
import 'category_empty.dart';

class CategoryBody extends StatelessWidget {
  const CategoryBody({super.key, required this.viewModel});

  final AllCategoriesScreenProvider viewModel;

  @override
  Widget build(BuildContext context) {
    // Get device screen width for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    // Determine grid column count and aspect ratio based on screen size
    final int crossAxisCount = isSmallScreen ? 2 : 2;
    final double childAspectRatio = isSmallScreen ? 3 / 2 : 2.2;

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      dev.log('Error: ${viewModel.error}');
      return CategoryEmpty(viewModel: viewModel);
    }

    if (viewModel.categories.isEmpty) {
      if (viewModel.searchQuery.isNotEmpty) {
        return Center(
          child: Text(
            'No categories found matching "${viewModel.searchQuery}"',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return const Center(
          child: Text(
            'No categories available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
    }

    // Show GridView with categories
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          return CategoryCard(
            category: category,
            onTap: () => context.push('/category-services/${category.id}'),
            // onTap:
            //     () => context.push(
            //       '${EadProductRoute.eadServices}/${category.id}/${ProductSearchBy.category.name}',
            //     ),
          );
        },
      ),
    );
  }
}
