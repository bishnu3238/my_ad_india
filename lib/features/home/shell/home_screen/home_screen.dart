// home_screen.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:my_ad/core/constant/trasnlation_key.dart';
// import 'package:my_ad/utils/translation_service/easy_localize.dart';
import 'package:pack/auth/custom_auth.dart';
import '../../../../core/data/model/model.dart';
import '../../../../utils/widgets/no_internet_connection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/services/service.dart';
import '../../../myad_categories/core/all_category_route.dart';
import '../../../error/error_page.dart';
import 'package:provider/provider.dart';
import 'package:pack/pack.dart';
import '../../../../utils/includes/custom_drawer.dart';
import '../../../all_services/core/all_services_route.dart';
import '../../../post_requirement/core/route.dart';
import '../../core/first_time_popup_manager.dart';
import 'body/body.dart';
import '../../../../utils/widgets/header_section.dart';
import 'body/home_category_section.dart';
import 'body/home_search_bar.dart';
import 'body/home_services_serction.dart';
import 'core/home_provider.dart';
import 'body/home_banner_section.dart';
import 'body/nearby_providers_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late final HomeScreenProvider _homeProvider;
  late final AuthProviderModel<UserModel> _authProvider;

  @override
  bool get wantKeepAlive => true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FirstTimePopupManager.showReferralPopupIfNeeded(context),
    );
    _homeProvider = context.read<HomeScreenProvider>();
    _authProvider = context.read<AuthProviderModel<UserModel>>();
    _authProvider.addListener(_checkAuthStatus);
    _checkConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkConnectivity() async {
    await _homeProvider.checkConnectivity();
  }

  void _setupConnectivityListener() async {
    await _homeProvider.setupConnectivityListener();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: HomeAppBar(),
          drawer: CustomDrawer(),
          body: Consumer<HomeScreenProvider>(
            builder: (context, viewModel, _) {
              if (!viewModel.state.isOnline) {
                return NoConnectionWidget(
                  onRetryTap:
                      () =>
                          viewModel
                            ..checkConnectivity()
                            ..fetchData(),
                  isLoading: viewModel.state.isOnline,
                );
              }

              if (viewModel.isLoading) {
                return _buildShimmerLoading();
              }

              if (viewModel.error != null) {
                return ErrorPage(
                  title: 'Error',
                  errorMessage: viewModel.error ?? 'Something went wrong',
                  onRetry: viewModel.fetchData,
                );
              }

              return RefreshIndicator(
                onRefresh: viewModel.fetchData,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  // controller: _homeProvider.state.scrollController,
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: HomeSearchBar(),
                      ),
                    ),
                    // Banner Section
                    SliverToBoxAdapter(child: const HomeBanner()),
                    // Quick Actions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: 16.symmetricHV(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                Icons.category_outlined,
                                context,
                                TranslationKey.allCategories.key,
                                onTap:
                                    () => context.push(
                                      AllCategoriesRoute.allCategory,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickActionCard(
                                Icons.post_add_rounded,
                                context,
                                TranslationKey.addPost.key,
                                onTap:
                                    () => context.push(
                                      PostRequirementRoute.postRequirement,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Nearby Providers Section
                    SliverToBoxAdapter(child: const NearbyProvidersSection()),
                    // Category Section
                    const HomeCategorySection(),
                    // Services Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: HeaderSection(
                          title: 'services',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap:
                              () => context.push(
                                '${AllServicesRoute.allServices}/ /${ShowServicesBy.all.name}',
                              ),
                        ),
                      ),
                    ),
                    const HomeServicesSection(),
                    // Featured Providers Carousel (optional, can be implemented as needed)
                    // SliverToBoxAdapter(child: FeaturedProvidersCarousel()),
                    // Top Ranked Categories
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(top: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top-Ranked Categories For You',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTabBar(),
                          ],
                        ),
                      ),
                    ),
                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    // Use a shimmer or skeleton loader for the whole page
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            2,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: i == 0 ? 16 : 8),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildNoConnectionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await _checkConnectivity();
              if (_homeProvider.state.isOnline) {
                _homeProvider.fetchData();
              }
            },
            icon: const Icon(Icons.refresh),
            label: Text(context.tr(TranslationKey.retry.key)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    BuildContext context,
    String text, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: 8.0.all,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(
                context.tr(text),
                style: GoogleFonts.poppins(
                  fontSize: ScreenUtils().getFontSize(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTabController(
        length: 2,
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.transparent,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(
              child: Text(
                'POPULAR',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            Tab(
              child: Text(
                'B2B',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    _authProvider.removeListener(_checkAuthStatus);
    super.dispose();
  }

  void _checkAuthStatus() {
    final userName =
        _authProvider.isAuthenticated ? _authProvider.user!.name : 'Guest';
    _authProvider.isAuthenticated
        ? NotifyService.googleFilesStyle(
          context: context,
          message: 'Welcome $userName',
          duration: 3.seconds,
        )
        : NotifyService.googleFilesStyle(
          context: context,
          message: 'Logout ...',
          duration: 2.seconds,
          color: context.colorScheme.errorContainer,
        );
  }
}
