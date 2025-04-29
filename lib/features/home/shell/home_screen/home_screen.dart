// home_screen.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../utils/widgets/no_internet_connection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/services/service.dart';
import '../../../all_category/core/all_category_route.dart';
import '../../../error/error_page.dart';
import 'package:provider/provider.dart';
import 'package:pack/pack.dart';
import '../../../../utils/includes/custom_drawer.dart';
import '../../../all_services/core/all_services_route.dart';
import '../../core/first_time_popup_manager.dart';
import 'body/body.dart';
import '../../../../utils/widgets/header_section.dart';
import 'body/home_category_section.dart';
import 'body/home_search_bar.dart';
import 'body/home_services_serction.dart';
import 'core/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late final HomeScreenProvider _homeProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FirstTimePopupManager.showReferralPopupIfNeeded(context);
    _homeProvider = context.read<HomeScreenProvider>();
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
      child: Scaffold(
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
              return BuildShimmerLoading();
            }

            if (viewModel.error != null) {
              return ErrorPage(
                title: 'Error',
                errorMessage: viewModel.error!,
                onRetry: viewModel.fetchData,
              );
            }

            return RefreshIndicator(
              onRefresh: viewModel.fetchData,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),

                controller: _homeProvider.state.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        HomeSearchBar(),
                        const SizedBox(height: 16),
                        const HomeBanner(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  //
                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              Icons.category_outlined,
                              'All Categories',
                              onTap:
                                  () => context.push(
                                    AllCategoriesRoute.allCategory,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: _buildQuickActionCard(
                              Icons.post_add_rounded,
                              'Post Requirement',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //
                  HomeCategorySection(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: HeaderSection(
                        title: 'Services',
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
                  HomeServicesSection(),

                  // Top Ranked Categories
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
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
            label: const Text('Retry'),
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
                text,
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
    super.dispose();
  }
}
