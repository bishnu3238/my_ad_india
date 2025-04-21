// category_services_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import '../../../core/data/model/product/category_model.dart';
import '../../../core/data/model/product/service_model.dart';
import '../../../utils/widgets/header_section.dart';
import '../ead_products/core/ead_product_navigator.dart';
import '../error/error_page.dart';
import 'core/category_service_provider.dart';
import 'core/category_service_state.dart';
import '../../../utils/widgets/no_internet_connection_page.dart';

class CategoryServicesPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryServicesPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryServicesPage> createState() => _CategoryServicesPageState();
}

class _CategoryServicesPageState extends State<CategoryServicesPage> {
  late final CategoryServicesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<CategoryServicesProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    await _provider.checkConnectivity();
    if (_provider.state.isOnline) {
      await _provider.fetchCategoryServices(widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: Consumer<CategoryServicesProvider>(
        builder: (context, provider, _) {
          // Check for connectivity
          if (!provider.state.isOnline) {
            return NoConnectionWidget(
              onRetryTap: () async {
                await provider.checkConnectivity();
                if (provider.state.isOnline) {
                  provider.fetchCategoryServices(widget.categoryId);
                }
              },
              isLoading: provider.state.isCheckingConnectivity,
            );
          }

          // Check for loading state
          if (provider.state.isLoading) {
            return const Center(child: BuildShimmerLoading());
          }

          // Check for error state
          if (provider.state.error != null) {
            return ErrorPage(
              title: 'Error',
              errorMessage: provider.state.error!,
              onRetry: () => provider.fetchCategoryServices(widget.categoryId),
            );
          }

          // Check for empty state
          if (provider.state.services.isEmpty) {
            return _buildEmptyState();
          }

          // Display services
          return RefreshIndicator(
            onRefresh: () => provider.fetchCategoryServices(widget.categoryId),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildCategoryHeader(widget.categoryName),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      // Show View All card if needed
                      if (provider.state.shouldShowViewAll &&
                          index == provider.state.visibleServices.length) {
                        return _buildViewAllCard(context, provider);
                      }
                      return _buildServiceCard(
                        context,
                        provider.state.visibleServices[index],
                      );
                    }, childCount: provider.state.visibleItemCount),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services in $categoryName',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Consumer<CategoryServicesProvider>(
          builder: (context, provider, _) {
            return Text(
              '${provider.state.totalServices} services available',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            );
          },
        ),
        const SizedBox(height: 16),
        Consumer<CategoryServicesProvider>(
          builder: (context, provider, _) {
            return provider.state.isSearchActive
                ? _buildActiveSearchBar(provider)
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActiveSearchBar(CategoryServicesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Searching: "${provider.state.searchQuery}"',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => provider.clearSearch(),
            color: Colors.grey[700],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    return GestureDetector(
      onTap:
          () => context.push(
            '${EadProductRoute.eadServices}/${service.id}/${ProductSearchBy.service.name}',
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Hero(
                tag: 'service_image_${service.id}',
                child: ImageView(
                  source: ImageSource.network,
                  path: service.fullImageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name
                  AutoSizeText(
                    service.serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: ScreenUtils().getFontSize(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Category
                  Text(
                    service.categoryName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: ScreenUtils().getFontSize(11),
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  if (service.price > 0)
                    Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCard(
    BuildContext context,
    CategoryServicesProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.showAllServices(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'View All\n${provider.state.totalServices} Services',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Services Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any services in this category',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _provider.fetchCategoryServices(widget.categoryId),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final provider = context.read<CategoryServicesProvider>();

    if (provider.state.isSearchActive) {
      searchController.text = provider.state.searchQuery;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Search Services',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Enter service name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.searchServices(searchController.text);
                  Navigator.pop(context);
                },
                child: Text('Search', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final provider = context.read<CategoryServicesProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort Services',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSortOption(
                  context,
                  provider,
                  'Name (A-Z)',
                  SortOption.nameAsc,
                ),
                _buildSortOption(
                  context,
                  provider,
                  'Name (Z-A)',
                  SortOption.nameDesc,
                ),
                _buildSortOption(
                  context,
                  provider,
                  'Price (Low to High)',
                  SortOption.priceLowToHigh,
                ),
                _buildSortOption(
                  context,
                  provider,
                  'Price (High to Low)',
                  SortOption.priceHighToLow,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    CategoryServicesProvider provider,
    String title,
    SortOption option,
  ) {
    return InkWell(
      onTap: () {
        provider.sortServices(option);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Radio<SortOption>(
              value: option,
              groupValue: provider.state.sortOption,
              onChanged: (value) {
                provider.sortServices(value!);
                Navigator.pop(context);
              },
            ),
            Text(title, style: GoogleFonts.poppins(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
