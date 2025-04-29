import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/features/chat/core/chat_navigator.dart';
import 'package:my_ad/features/chat/core/chat_navigation.dart';
import 'package:my_ad/features/chat/services/chat_manager.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/injector/dependency_injection.dart';
import '../../../core/services/product_service.dart';
import '../../../core/data/model/model.dart';
import '../core/ead_product_view_model.dart';
import 'core/ead_product_details_viewmodel.dart';
import 'widgets/product_image_carousel.dart';
import 'widgets/product_info_section.dart';
import 'widgets/merchant_info_card.dart';
import 'widgets/inquiry_form.dart';
import 'widgets/similar_products_section.dart';
import 'widgets/contact_action_buttons.dart';

class EadProductDetails extends StatefulWidget {
  const EadProductDetails({super.key, required this.provider});
  final EadProductsViewModel provider;

  @override
  State<EadProductDetails> createState() => _EadProductDetailsState();
}

class _EadProductDetailsState extends State<EadProductDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final viewModel = Provider.of<ProductDetailsViewModel>(
        context,
        listen: false,
      );
      viewModel.setSelectedTabIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eadProductsViewModel = widget.provider;
    final product =
        eadProductsViewModel.products.isNotEmpty
            ? eadProductsViewModel.products.first
            : null;

    if (product == null) {
      return Scaffold(body: Center(child: Text('Product not found')));
    }

    return ChangeNotifierProvider(
      create:
          (_) => ProductDetailsViewModel(
            product: product,
            productStore: Provider.of(context, listen: false),
            service: DependencyInjector.get<ProductService>(),
          ),
      child: Consumer<ProductDetailsViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.state;

          return Scaffold(
            body: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      _buildAppBar(context, product, viewModel),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'Details'),
                              Tab(text: 'Offers'),
                              Tab(text: 'Contact'),
                            ],
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor:
                                context.colorScheme.onSurfaceVariant,
                            indicatorColor: context.colorScheme.primary,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(context, product, viewModel),
                      _buildDetailsTab(context, product, viewModel),
                      _buildOffersTab(context, product, viewModel),
                      _buildContactTab(context, product, viewModel),
                    ],
                  ),
                ),

                // Error message
                if (state.errorMessage != null)
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: viewModel.clearError,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Inquiry form
                if (state.showInquiryForm)
                  InquiryForm(
                    viewModel: viewModel,
                    onClose: viewModel.toggleInquiryForm,
                  ),

                // Inquiry success message
                if (state.inquirySubmitted)
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Your inquiry has been submitted successfully!',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed:
                                  () => viewModel.updateState(
                                    viewModel.state.copyWith(
                                      inquirySubmitted: false,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: ContactActionButtons(
              product: product,
              viewModel: viewModel,
              onCall: () => _launchPhone(product.merchant.mobile),
              onWhatsApp: () => _launchWhatsApp(product.merchant.mobile),
              onChat: () => _navigateToChat(product),
              onInquiry: viewModel.toggleInquiryForm,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageCarousel(product: product),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colorScheme.surface),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: context.colorScheme.surface),
            onPressed: () => _shareProduct(product),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProductInfoSection(product: product),
        const SizedBox(height: 16),
        SimilarProductsSection(viewModel: viewModel),
      ],
    );
  }

  Widget _buildDetailsTab(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final description = viewModel.getDecodedDescription();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About this service',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Location',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.cityName}, ${product.stateName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.home, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.address,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (product.latitude != 0 && product.longitude != 0)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                      child: Icon(Icons.map, size: 50, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersTab(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final offers = viewModel.getDecodedOffers();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (product.offerStatus == OfferStatus.active) ...[
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_offer, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Special Offer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offers.isNotEmpty
                        ? offers
                        : 'Contact merchant for special offers!',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Rate: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${product.planRate.toString()} INR',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 80,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No active offers available',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact the merchant for more information',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContactTab(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MerchantInfoCard(product: product),
        const SizedBox(height: 16),
        _buildChatButton(context, product),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, ProductModel product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start a Conversation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Chat directly with the service provider to discuss your requirements.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Chat with Service Provider'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () => _navigateToChat(product),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(ProductModel product) async {
    // Debug logging
    dev.log('Navigate to chat with merchant: ${product.merchant.id}');

    final authProvider = context.read<AuthProviderModel<UserModel>>();
    final userId = authProvider.user?.id ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to chat with the service provider'),
        ),
      );
      return;
    }

    final merchantId = product.merchant.id;
    final merchantName = product.merchant.companyName;
    final merchantImage = product.merchant.imgUrl;

    final chatManager = Provider.of<ChatManager>(context, listen: false);

    try {
      // Show loading indicator
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => const Center(child: CircularProgressIndicator()),
      // );

      if (!chatManager.isInitialized) {
        chatManager.initialize(
          ApiConfig.baseChatUrl, // Your server URL
          userId.toString(),
          'customer',
        );
      }
      dev.log('Customer ID: $userId, Merchant ID: $merchantId');

      String processedImageUrl = '';
      if (merchantImage.isNotEmpty) {
        if (merchantImage.startsWith('http://') ||
            merchantImage.startsWith('https://')) {
          processedImageUrl = merchantImage;
        } else {
          processedImageUrl = 'https://api.myad.com/uploads/$merchantImage';
        }
      }

      // Use the ChatNavigation helper to open chat
      await ChatNavigation.openChatWithMerchant(
        context,
        chatManager,
        userId.toString(),
        merchantId.toString(),
        merchantName,
        processedImageUrl,
      );
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      dev.log('Error opening chat: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
    }
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchWhatsApp(String phone) async {
    String message = "Hello, I'm interested in your service.";
    var encodedMessage = Uri.encodeComponent(message);

    final url = 'https://wa.me/$phone?text=$encodedMessage';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email?subject=Inquiry about your service';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareProduct(ProductModel product) {
    final text =
        'Check out ${product.serviceName} by ${product.merchant.companyName}. Contact them at ${product.merchant.mobile}';
    Share.share(text);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
