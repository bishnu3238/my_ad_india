import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/features/category_services/core/category_service_route.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../ead_products/core/ead_product_navigator.dart';
import 'body/category_card.dart';
import 'body/category_search_bar.dart';
import 'core/all_category_view_modal.dart';

// Main All Categories Page
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    // Access the view model through provider
    final viewModel = Provider.of<AllCategoriesScreenProvider>(context);

    // Get device screen width for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    // Determine grid column count and aspect ratio based on screen size
    final int crossAxisCount = isSmallScreen ? 2 : 2;
    final double childAspectRatio = isSmallScreen ? 3 / 2 : 2.2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CupertinoNavigationBar(
        middle: const Text('All Categories'),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      body: Column(
        children: [
          // Cupertino Search Bar
          CategorySearchBar(viewModel: viewModel),

          // Main Content
          Expanded(
            child: _buildContent(viewModel, crossAxisCount, childAspectRatio),
          ),
        ],
      ),
    );
  }

  // Build content based on view model state
  Widget _buildContent(
    AllCategoriesScreenProvider viewModel,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load categories',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
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
