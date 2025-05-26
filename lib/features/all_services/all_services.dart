// ***** UI IMPLEMENTATION *****
// lib/features/services/presentation/screens/all_services_screen.dart

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/features/all_services/core/all_services_route.dart';
import 'package:my_ad/features/favorites/core/favorites_route.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../../utils/widgets/svg_icon_widget.dart';
import 'body/filter_bottom_sheet.dart';
import 'body/service_card.dart';
import 'core/all_service_view_model.dart';
import 'core/service_list_state.dart';

class AllServicesScreen extends StatefulWidget {
  final String categoryId;
  final ShowServicesBy showServiceBy;
  const AllServicesScreen({
    super.key,
    required this.categoryId,
    required this.showServiceBy,
  });

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  late ScrollController _chipScrollController;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chipScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceListViewModel>().fetchServices(
        widget.showServiceBy,
        widget.categoryId,
      );
    });

    _searchController.addListener(() {
      context.read<ServiceListViewModel>().searchServices(
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Discover Ead Services',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () => FavoritesRoute.openPage(context),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Find your product',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: InkWell(
                  onTap: () => _showFilterBottomSheet(context),
                  child: const Icon(Icons.filter_list),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category Chips
          Consumer<ServiceListViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.state is ServiceListLoaded) {
                final state = viewModel.state as ServiceListLoaded;

                // Find index of selected category
                final selectedIndex = state.categories.indexOf(
                  state.selectedCategory,
                );

                // Scroll after the build is completed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_chipScrollController.hasClients && selectedIndex >= 0) {
                    double offset =
                        selectedIndex * 100.0; // assume each chip ~100px width
                    _chipScrollController.animateTo(
                      offset,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });

                return SizedBox(
                  height: 40, // or whatever your chip height is
                  child: ListView.separated(
                    controller: _chipScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: state.categories.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected = category == state.selectedCategory;
                      return _buildCategoryChip(
                        category,
                        isSelected,
                        () => viewModel.selectCategory(category),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Services Grid
          Expanded(
            child: Consumer<ServiceListViewModel>(
              builder: (context, viewModel, child) {
                switch (viewModel.state.runtimeType) {
                  case ServiceListInitial _:
                  case ServiceListLoading _:
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );

                  case ServiceListError:
                    final errorState = viewModel.state as ServiceListError;
                    return _buildErrorState(errorState.message, viewModel);

                  case ServiceListLoaded:
                    final loadedState = viewModel.state as ServiceListLoaded;
                    return _buildServicesGrid(context, loadedState, viewModel);

                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: theme.primary,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildErrorState(String message, ServiceListViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.retryFetch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(
    BuildContext context,
    ServiceListLoaded state,
    ServiceListViewModel viewModel,
  ) {
    if (state.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIconWidget(iconPath: SvgIcons.orderIcon),
            const SizedBox(height: 10),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No results found for "${state.searchQuery}"'
                  : 'No products available',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: state.services.length,
      itemBuilder: (context, index) {
        final service = state.services[index];
        return ServiceCard(
          service: service,
          isFavorite: viewModel.isFavorite(service.id),
          onFavoriteToggle: () => viewModel.toggleFavorite(service.id),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FilterBottomSheet(
            onApplyFilters: (SortOption option) {
              context.read<ServiceListViewModel>().sortServices(option);
              Navigator.pop(context);
            },
          ),
    );
  }
}
