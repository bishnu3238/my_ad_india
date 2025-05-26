// lib/features/favorites/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/data/model/model.dart';
import 'core/favorites_view_model.dart';
import 'core/favorites_state.dart';
import 'widgets/favorite_service_card.dart';
import 'widgets/favorites_sort_bottom_sheet.dart';
import 'widgets/favorites_empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
      _animationController.forward();
    });

    _searchController.addListener(() {
      context.read<FavoritesViewModel>().searchFavorites(_searchController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(context, colorScheme),
              _buildSearchAndFilters(context, colorScheme),
              Expanded(
                child: Consumer<FavoritesViewModel>(
                  builder: (context, viewModel, child) {
                    return _buildContent(context, viewModel, colorScheme);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'My Favorites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Consumer<FavoritesViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.state is FavoritesLoaded) {
                final state = viewModel.state as FavoritesLoaded;
                return PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                  onSelected: (value) async {
                    switch (value) {
                      case 'clear_all':
                        _showClearAllDialog(context, viewModel);
                        break;
                      case 'refresh':
                        await viewModel.refreshFavorites();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                    if (state.favoriteServices.isNotEmpty)
                      PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, color: colorScheme.error),
                            const SizedBox(width: 12),
                            Text('Clear All', style: TextStyle(color: colorScheme.error)),
                          ],
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ColorScheme colorScheme) {
    return Consumer<FavoritesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.state is! FavoritesLoaded) return const SizedBox.shrink();

        final state = viewModel.state as FavoritesLoaded;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSearchExpanded ? 56 : 48,
                child: TextField(
                  controller: _searchController,
                  onTap: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      _isSearchExpanded = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.searchFavorites('');
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter and View Options
              Row(
                children: [
                  // Results count
                  Expanded(
                    child: Text(
                      state.searchQuery.isEmpty
                          ? '${state.favoriteServices.length} favorite${state.favoriteServices.length != 1 ? 's' : ''}'
                          : '${state.filteredServices.length} result${state.filteredServices.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Sort button
                  TextButton.icon(
                    onPressed: () => _showSortBottomSheet(context, viewModel, state.sortOption),
                    icon: Icon(state.sortOption.icon, size: 18),
                    label: Text(state.sortOption.displayName),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // View toggle
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewToggleButton(
                          icon: Icons.grid_view,
                          isSelected: state.isGridView,
                          onPressed: () {
                            if (!state.isGridView) viewModel.toggleViewMode();
                          },
                          colorScheme: colorScheme,
                        ),
                        _buildViewToggleButton(
                          icon: Icons.list,
                          isSelected: !state.isGridView,
                          onPressed: () {
                            if (state.isGridView) viewModel.toggleViewMode();
                          },
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      FavoritesViewModel viewModel,
      ColorScheme colorScheme,
      ) {
    switch (viewModel.state.runtimeType) {
      case FavoritesInitial:
      case FavoritesLoading:
        return _buildLoadingState(colorScheme);

      case FavoritesEmpty:
        return const FavoritesEmptyState();

      case FavoritesError:
        final errorState = viewModel.state as FavoritesError;
        return _buildErrorState(errorState.message, viewModel, colorScheme);

      case FavoritesLoaded:
        final loadedState = viewModel.state as FavoritesLoaded;
        return _buildFavoritesList(context, loadedState, viewModel, colorScheme);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading favorites...',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      String message,
      FavoritesViewModel viewModel,
      ColorScheme colorScheme,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => viewModel.refreshFavorites(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
      BuildContext context,
      FavoritesLoaded state,
      FavoritesViewModel viewModel,
      ColorScheme colorScheme,
      ) {
    if (state.filteredServices.isEmpty && state.searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(state.searchQuery, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshFavorites(),
      color: colorScheme.primary,
      child: state.isGridView
          ? _buildGridView(state.filteredServices, viewModel, colorScheme)
          : _buildListView(state.filteredServices, viewModel, colorScheme),
    );
  }

  Widget _buildSearchEmptyState(String query, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<ServiceModel> services,
      FavoritesViewModel viewModel,
      ColorScheme colorScheme,
      ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return FavoriteServiceCard(
          service: services[index],
          isGridView: true,
          onFavoriteToggle: () => viewModel.toggleFavorite(services[index].id),
        );
      },
    );
  }

  Widget _buildListView(
      List<ServiceModel> services,
      FavoritesViewModel viewModel,
      ColorScheme colorScheme,
      ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return FavoriteServiceCard(
          service: services[index],
          isGridView: false,
          onFavoriteToggle: () => viewModel.toggleFavorite(services[index].id),
        );
      },
    );
  }

  void _showSortBottomSheet(
      BuildContext context,
      FavoritesViewModel viewModel,
      FavoritesSortOption currentOption,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavoritesSortBottomSheet(
        currentSortOption: currentOption,
        onSortSelected: (option) {
          viewModel.sortFavorites(option);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text(
          'This will remove all services from your favorites list. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              viewModel.clearAllFavorites();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}