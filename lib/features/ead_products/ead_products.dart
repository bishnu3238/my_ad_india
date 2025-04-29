import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/services/auth_service.dart';
import 'package:my_ad/features/chat/services/chat_service.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/data/model/model.dart';

import '../../provider_state/location_provider.dart';
import '../../utils/widgets/svg_icon_widget.dart';
import 'body/category_chips.dart';
import 'body/empty_error_widgets.dart';
import 'body/filtered_buttom_sheet.dart';
import 'body/loading_shimmer.dart';
import 'body/location_detector.dart';
import 'body/product_card.dart';
import 'core/ead_product_navigator.dart';
import 'core/ead_product_view_model.dart';

class EadProducts extends StatefulWidget {
  const EadProducts({super.key});

  @override
  State<EadProducts> createState() => _EadProductsState();
}

class _EadProductsState extends State<EadProducts>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showLocationSelector = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      final viewModel = Provider.of<EadProductsViewModel>(
        context,
        listen: false,
      );
      viewModel.refreshData();
    });
  }

  void _scrollListener() {
    final viewModel = Provider.of<EadProductsViewModel>(context, listen: false);
    if (_scrollController.position.pixels > 80 &&
        viewModel.state.isSearchBarVisible) {
      viewModel.toggleSearchBarVisibility(false);
    } else if (_scrollController.position.pixels <= 80 &&
        !viewModel.state.isSearchBarVisible) {
      viewModel.toggleSearchBarVisibility(true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EadProductsViewModel>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildAppBar(viewModel, theme)];
        },
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(viewModel, theme, size, locationProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context, viewModel),
        tooltip: 'Filter Products',
        child: const SvgIconWidget(iconPath: SvgIcons.filterIcon),
      ),
    );
  }

  SliverAppBar _buildAppBar(EadProductsViewModel viewModel, ThemeData theme) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: kToolbarHeight * 2.5,
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      title: Text(
        viewModel.title,
        style: GoogleFonts.poppins(
          color: theme.colorScheme.onSurface,
          fontSize: ScreenUtils().getFontSize(15),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              start: 16,
              bottom: 16,
            ),
            centerTitle: false,
            background: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: kToolbarHeight + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location selector
                  LocationDetector(
                    theme: theme,
                    showLocationSelector: _showLocationSelector,
                    onTap: () {
                      setState(() {
                        _showLocationSelector = !_showLocationSelector;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (viewModel.state.isSearchBarVisible)
                    _buildSearchBar(viewModel, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(EadProductsViewModel viewModel, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => viewModel.searchServices(value),
        decoration: InputDecoration(
          hintText: 'Search "${viewModel.title}"',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.clearSearch();
                    },
                  )
                  : IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice search coming soon'),
                        ),
                      );
                    },
                  ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    EadProductsViewModel viewModel,
    ThemeData theme,
    Size size,
    LocationProvider locationProvider,
  ) {
    // Show location selector dropdown
    if (_showLocationSelector) {
      return _buildLocationSelector(theme, locationProvider, viewModel);
    }

    // Show loading, error, or empty states
    if (viewModel.state.isLoading) {
      return LoadingShimmer();
    }

    if (viewModel.state.error != null) {
      return ErrorStateWidget(
        error: viewModel.state.error!,
        onRetry: () => viewModel.refreshData(),
      );
    }

    if (viewModel.products.isEmpty) {
      return EmptyStateWidget(
        searchQuery: viewModel.searchQuery,
        onClearSearch: viewModel.clearSearch,
      );
    }

    // Main content - Products display
    return Column(
      children: [
        // Sort and view options bar
        _buildSortAndViewOptions(viewModel, theme),

        // Category chips - horizontal scrolling categories
        if (viewModel.products.isNotEmpty) CategoryChips(),

        // Main product grid/list view
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => viewModel.refreshData(),
            child: PageTransitionSwitcher(
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child:
                  viewModel.isGridView
                      ? _buildProductGrid(viewModel, locationProvider)
                      : _buildProductList(viewModel, locationProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortAndViewOptions(
    EadProductsViewModel viewModel,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String>(
            value: viewModel.selectedSortOption,
            icon: const Icon(Icons.keyboard_arrow_down),
            underline: Container(height: 0),
            onChanged: (String? newValue) {
              if (newValue != null) {
                viewModel.setSortOption(newValue);
              }
            },
            items:
                <String>[
                  'Recommended',
                  'Newest',
                  'Price: Low to High',
                  'Price: High to Low',
                  'Nearby',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              !viewModel.isGridView
                  ? Icons.view_list_rounded
                  : Icons.view_list_outlined,
              color:
                  !viewModel.isGridView
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            onPressed: () => viewModel.toggleViewMode(false),
          ),
          IconButton(
            icon: Icon(
              viewModel.isGridView ? Icons.grid_view_rounded : Icons.grid_view,
              color:
                  viewModel.isGridView
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            onPressed: () => viewModel.toggleViewMode(true),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    EadProductsViewModel viewModel,
    LocationProvider locationProvider,
  ) {
    return GridView.builder(
      key: const PageStorageKey('product_grid'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductDetails(context, product),
          onCall: () => _launchPhone(product.merchant.mobile),
          onChat: () => _launchWhatsApp(product.merchant.mobile),
          distanceFromUser: _calculateDistance(
            product.latitude,
            product.longitude,
            locationProvider.currentLocation,
          ),
        );
      },
    );
  }

  Widget _buildProductList(
    EadProductsViewModel viewModel,
    LocationProvider locationProvider,
  ) {
    return ListView.separated(
      key: const PageStorageKey('product_list'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewModel.products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductDetails(context, product),
          onCall: () => _launchPhone(product.merchant.mobile),
          onChat: () => _launchWhatsApp(product.merchant.mobile),
          distanceFromUser: _calculateDistance(
            product.latitude,
            product.longitude,
            locationProvider.currentLocation,
          ),
        );
      },
    );
  }

  Widget _buildLocationSelector(
    ThemeData theme,
    LocationProvider locationProvider,
    EadProductsViewModel viewModel,
  ) {
    final popularCities = [
      'Kolkata',
      'Delhi',
      'Mumbai',
      'Chennai',
      'Bangalore',
      'Hyderabad',
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                'Select Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Detect My Location'),
                onPressed: () async {
                  setState(() {
                    _showLocationSelector = false;
                  });
                  await locationProvider.detectUserLocation();
                  // Refresh products with new location
                  viewModel.refreshData();
                },
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Popular Cities'),
              ),
              ...popularCities.map(
                (city) => ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color:
                        city == locationProvider.currentLocation
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(city),
                  trailing:
                      city == locationProvider.currentLocation
                          ? Icon(Icons.check, color: theme.colorScheme.primary)
                          : null,
                  onTap: () {
                    locationProvider.setCity(city);
                    setState(() {
                      _showLocationSelector = false;
                    });
                    // Refresh products with new location
                    viewModel.refreshData();
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Recently Used'),
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: const Text('New Delhi'),
                onTap: () {
                  locationProvider.setCity('New Delhi');
                  setState(() {
                    _showLocationSelector = false;
                  });
                  viewModel.refreshData();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Calculate distance based on location name (this would be replaced by actual lat/long calculation)
  String _calculateDistance(double lat, double lng, String locationName) {
    // This is a placeholder. In a real implementation, you would:
    // 1. Get current user's lat/long from LocationProvider
    // 2. Calculate distance using Haversine formula or similar

    // For demo, return random distances based on location
    switch (locationName) {
      case 'Kolkata':
        return '${(2 + (lat % 3)).toStringAsFixed(1)} km';
      case 'Delhi':
        return '${(5 + (lat % 5)).toStringAsFixed(1)} km';
      case 'Mumbai':
        return '${(8 + (lat % 4)).toStringAsFixed(1)} km';
      default:
        return '${(10 + (lat % 7)).toStringAsFixed(1)} km';
    }
  }

  void _navigateToProductDetails(
    BuildContext context,
    ProductModel product,
  ) async {
    if (!await AuthCheckService.checkAuthAndShowPopupIfNeeded(context)) return;
    if (context.mounted) {
      context.push(
        '${EadProductRoute.eadServices}/${product.id}/${ProductSearchBy.product.name}${EadProductRoute.eadServiceDetails}',
        extra: context.read<EadProductsViewModel>(),
      );
    }
  }

  void _launchPhone(String phoneNumber) async {
    if (!await AuthCheckService.checkAuthAndShowPopupIfNeeded(context)) return;

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not launch phone call');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while launching phone call');
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        _showErrorSnackBar('Could not open WhatsApp');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while opening WhatsApp');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    EadProductsViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FilterBottomSheet(viewModel: viewModel, theme: theme);
      },
    );
  }
}
